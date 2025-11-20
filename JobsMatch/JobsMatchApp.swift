//
//  JobsMatchApp.swift
//  JobsMatch
//
//  Created by ivans Android on 3/24/24.
//

import SwiftUI
import Firebase
import SendbirdUIKit
import SendbirdChatSDK
import UserNotifications
import FirebaseDynamicLinks
import Foundation
import UserNotifications
import GoogleSignIn
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var pendingDeviceToken: Data?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        guard let APP_ID = Bundle.main.object(forInfoDictionaryKey: "SENDBIRD_APP_ID") as? String, !APP_ID.isEmpty else {
            fatalError("Sendbird App ID is missing or invalid.")
        }
        //let sendbirdApiToken = Bundle.main.object(forInfoDictionaryKey: "SENDBIRD_API_TOKEN") as? String ?? ""
        SendbirdUI.initialize(applicationId: APP_ID) { _ in
                    // Leave parameter configuration empty for now
            } startHandler: {
                print("DEBUG: Sendbird initialization started")
            } migrationHandler: {
                print("DEBUG: Sendbird migration in progress")
            } completionHandler: { [weak self] error in
                if let error = error {
                    print("ERROR: Sendbird initialization failed: \(error)")
                } else {
                    print("SUCCESS: Sendbird initialized successfully")
                    SendbirdManager.shared.isSendbirdInitialized = true
                    
                    // If we have a pending token, try to register it now
                    if let pendingToken = self?.pendingDeviceToken {
                        self?.registerTokenWithSendbird(deviceToken: pendingToken)
                    }
                }
            }
        
        UNUserNotificationCenter.current().delegate = self
        setupNotifications(application: application)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings{ settings in
            switch settings.authorizationStatus{
            case .authorized:
                self.dispatchNotification(
                    identifier: "daily-notif-jobsmatch-1",
                    title: "Have you Swiped Today?",
                    body: "Come back and find your Dream Job",
                    hour: 12,
                    minute: 30
                )

                // Dispatch the second notification
                self.dispatchNotification(
                    identifier: "daily-notif-jobsmatch-2",
                    title: "Keep Tabs on Your Progress!",
                    body: "View your application status on the dashboard",
                    hour: 18,
                    minute: 0
                )
            case .denied:
                return
            case .notDetermined:
                return
            case .provisional:
                return
            case .ephemeral:
                return
            @unknown default:
                return
            }
        }
        return true
    }
    
    
    func dispatchNotification(identifier: String, title: String, body: String, hour: Int, minute: Int, isDaily: Bool = true) {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Remove any existing notification with the same identifier to avoid duplicates
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])

        notificationCenter.add(request)
    }
    
    
    //google sign in
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    private func setupNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    print("DEBUG: Notification permission granted")
                }
            } else if let error = error {
                print("ERROR: Notification permission error: \(error)")
            } else {
                print("DEBUG: Notification permission denied")
            }
        }
    }
    
    private func registerTokenWithSendbird(deviceToken: Data) {
        // Only proceed if Sendbird is initialized
        guard SendbirdManager.shared.isSendbirdInitialized else {
            print("DEBUG: Storing token for later registration")
            pendingDeviceToken = deviceToken
            return
        }
        SendbirdChat.registerDevicePushToken(deviceToken, unique: true) { status, error in
            if let error = error {
                print("ERROR: Failed to register device token: \(error)")
                if status == .pending {
                    print("DEBUG: Token registration pending - will retry after connection")
                    self.handlePendingTokenRegistration(deviceToken: deviceToken)
                }
            } else {
                print("SUCCESS: Device token registered with status: \(status)")
                NotificationCenter.default.post(
                    name: Notification.Name("DeviceTokenReceived"),
                    object: deviceToken
                )
            }
        }
    }
    
    private func handlePendingTokenRegistration(deviceToken: Data) {
            guard let userId = AuthService.shared.currentUser?.id else {
                print("DEBUG: No user ID available for pending token registration")
                return
            }
            
            SendbirdChat.connect(userId: userId) { [weak self] user, error in
                if let error = error {
                    print("ERROR: Failed to connect for token registration: \(error)")
                    return
                }
                
                if let token = SendbirdChat.getPendingPushToken() {
                    self?.registerTokenWithSendbird(deviceToken: token)
                }
            }
        }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            print("DEBUG: Received device token from APNS")
            registerTokenWithSendbird(deviceToken: deviceToken)
        }
    
    // Handle failed registration for remote notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("ERROR: Failed to register for remote notifications: \(error)")
        }
    
    // UNUserNotificationCenterDelegate method for handling foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
    
    // UNUserNotificationCenterDelegate method for handling user interactions with notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        completionHandler()
    }
    
    func unregisterFromNotifications() {
        SendbirdChat.unregisterAllPushToken { error in
            if let error = error {
                print("Failed to unregister push token from Sendbird: \(error.localizedDescription)")
            } else {
                print("Successfully unregistered push token from Sendbird")
            }
        }
    }
    
    
    
    private func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let link = dynamicLink.url else { return }
        let linkString = link.absoluteString
        
        // Check if this link is for verifying email (Firebase uses mode=verifyEmail)
        if linkString.contains("mode=verifyEmail") {
            // Extract the "oobCode" from the query
            if let oobCode = URLComponents(string: linkString)?
                .queryItems?
                .first(where: { $0.name == "oobCode" })?
                .value
            {
                // Apply the action code to complete verification
                Auth.auth().applyActionCode(oobCode) { error in
                    if let error = error {
                        print("Error applying action code for verification: \(error.localizedDescription)")
                    } else {
                        print("Email verification completed in-app.")
                        // Optionally reload user to reflect the verification
                        Auth.auth().currentUser?.reload { _ in
                            // Possibly post a notification or update your app's state
                        }
                    }
                }
            }
        }
        // If you also support signInLink or other modes, you would handle them here:
        // else if linkString.contains("mode=signIn") { ... }
        // else if linkString.contains("mode=resetPassword") { ... } etc.
    }
}




@main
struct JobsMatchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    @StateObject private var authServiceHost = AuthServiceHost()
    init() {
        FirebaseApp.configure()
        Auth.auth().addStateDidChangeListener { auth, user in
              if let u = user {
                print("✅ Firebase authenticated as \(u.uid)")
              } else {
                print("🚪 Not signed in – redirect to login before Firestore writes")
              }
            }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(authServiceHost)
                .onAppear {
                    uploadPDF() { _ in }
                }
        }
    }
    
    
    func uploadPDF(completion: @escaping (Result<String, Error>) -> Void) {
        print("UOLOADPDF CALLSED")
        let serverURL = URL(string: "")!
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let mimetype = "application/pdf"
        
        let filename = "resume.pdf"
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        
//        if let fileData = try? Data(contentsOf: ) {
//            body.append(fileData)
//        } else {
//            completion(.failure(NSError(domain: "InvalidFile", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not read file data"])))
//            return
//        }
        
        body.append("resume text example".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        request.timeoutInterval = 10
        
        // Start the upload task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("done", #line, #function)
            
            if let error = error {
                print(error, error.localizedDescription)
                print("returning", #line, #function)
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusError = NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected server response"])
                completion(.failure(statusError))
                print("returning", #line, #function, response ?? "")
                return
            }
            
            if let data = data, let result = String(data: data, encoding: .utf8) {
                completion(.success(result))
                print("returning", #line, #function, result)
            } else {
                let parseError = NSError(domain: "ResponseParsing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not parse server response"])
                completion(.failure(parseError))
                print("returning", #line, #function)
            }
        }
        
        task.resume()
    }
}




