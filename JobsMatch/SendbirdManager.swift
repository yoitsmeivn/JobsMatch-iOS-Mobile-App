//
//  SendbirdManager.swift
//  JobsMatch
//
//  Created by ivans Android on 7/19/24.
//
import Foundation
import SendbirdChatSDK
import SendbirdUIKit
import FirebaseAuth
import UIKit
import UserNotifications

class SendbirdManager: ObservableObject {
    static let shared = SendbirdManager()
    @Published var isConnected = false
    private var pushToken: Data?
    var isSendbirdInitialized = false
    private var notificationObserver: NSObjectProtocol?
    
    private init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("DeviceTokenReceived"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let deviceToken = notification.object as? Data {
                self?.handleDeviceToken(deviceToken)
            }
        }
    }
    
    private func handleDeviceToken(_ deviceToken: Data) {
        self.pushToken = deviceToken
        
        // Only register if we're connected
        if isConnected {
            registerDeviceToken(deviceToken)
        } else {
            print("DEBUG: Storing push token for later registration")
        }
    }
    
    private func registerDeviceToken(_ deviceToken: Data) {
        print("DEBUG: Attempting to register device token")
        
        SendbirdChat.registerDevicePushToken(deviceToken, unique: true) { status, error in
            if let error = error {
                print("ERROR: Failed to register device token: \(error.localizedDescription)")
                
                if status == .pending {
                    print("DEBUG: Token registration pending - will retry after connection")
                    // Store token for later registration
                    self.pushToken = deviceToken
                }
            } else {
                print("SUCCESS: Device token registered with status: \(status)")
            }
        }
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    print("DEBUG: Notification permissions granted")
                }
            } else if let error = error {
                print("ERROR: Failed to request notification permissions: \(error.localizedDescription)")
            } else {
                print("DEBUG: Notification permissions denied")
            }
        }
    }
    
    func connectUser(authService: AuthService) {
        guard let userId = UserDefaults.standard.string(forKey: "user_uuid") else {
            print("DEBUG: No user UUID found")
            return
        }
            
            guard isSendbirdInitialized else {
                print("DEBUG: Sendbird hasn't been initialized yet, will retry...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.connectUser(authService: authService)
                }
                return
            }
            
            // If user data isn't loaded or names are empty, wait and retry
            if !authService.isUserDataLoaded ||
               authService.currentUser?.full_name?.isEmpty ?? true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.connectUser(authService: authService)
                }
                return
            }
            
            guard let full_name = authService.currentUser?.full_name,
                  !full_name.isEmpty else {
                print("ERROR: User name data is still missing or empty after load")
                return
            }
            
            print("DEBUG: Proceeding with Sendbird connection for user: \(full_name)")
            
            // Request notification permissions
            requestNotificationPermissions()
            performSendbirdConnection(userId: userId, full_name: authService.currentUser?.full_name ?? "")
        }
        
        private func performSendbirdConnection(userId: String, full_name: String) {
            let nickname = "\(full_name)".trimmingCharacters(in: .whitespacesAndNewlines)
            print("DEBUG: Setting Sendbird nickname to: \(nickname)")
            
            // First update the user info
            let params = UserUpdateParams()
            params.nickname = nickname
            
            SendbirdChat.updateCurrentUserInfo(params: params, completionHandler:  { error in
                if let error = error {
                    print("ERROR: Failed to update Sendbird nickname: \(error.localizedDescription)")
                } else {
                    print("SUCCESS: Updated Sendbird nickname to: \(nickname)")
                }
            })
            
            // Then set up the UI user
            let user = SBUUser(userId: userId, nickname: nickname, profileURL: nil)
            SBUGlobals.currentUser = user
            
            SendbirdChat.setPushTemplate(name: "default")
            
            // Finally connect
            SendbirdChat.connect(userId: userId) { [weak self] (user, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("ERROR: Failed to connect to Sendbird: \(error.localizedDescription)")
                    return
                }
                
                print("SUCCESS: Connected to Sendbird with user ID: \(userId) and nickname: \(nickname)")
                
                DispatchQueue.main.async {
                    self.isConnected = true
                    
                    // Register push token if we have one stored
                    if let storedToken = self.pushToken {
                        self.registerDeviceToken(storedToken)
                    }
                    
                    // Check for any pending push tokens
                    if let pendingToken = SendbirdChat.getPendingPushToken() {
                        self.registerDeviceToken(pendingToken)
                    }
                }
            }
        }
    
    func disconnect() {
        SendbirdChat.unregisterAllPushToken { error in
            if let error = error {
                print("ERROR: Failed to unregister push token: \(error.localizedDescription)")
            } else {
                print("SUCCESS: Unregistered push token")
                
                SendbirdUI.disconnect {
                    DispatchQueue.main.async { [weak self] in
                        self?.isConnected = false
                        self?.pushToken = nil
                        print("DEBUG: Disconnected from Sendbird")
                    }
                }
            }
        }
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
