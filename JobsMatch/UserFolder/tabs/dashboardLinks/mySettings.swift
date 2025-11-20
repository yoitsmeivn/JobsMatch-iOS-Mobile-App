//
//  mySettings.swift
//  JobsMatch
//
//  Created by ivans Android on 6/19/24.
//


import SwiftUI
import UserNotifications

struct mySettings: View {
    @State private var notificationsEnabled: Bool = false
    @Environment(\.dismiss) var dismiss
    @StateObject var userManager = UserManager.shared
    @EnvironmentObject var authService: AuthService
    @State private var deleteAccountStarted: Bool = false

    
    var body: some View {
        Form {
            // Profile Section
            Section(header: Text("Account")) {
                HStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    VStack(alignment: .leading) {
                        Text("\(authService.currentUser?.full_name ?? "")")
                            .font(Font.custom("Orkney-Bold", size: 17))
                        Text(authService.currentUser?.email ?? "")
                            .foregroundColor(.gray)
                            .font(Font.custom("Orkney-Light", size: 17))
                    }
                }
                NavigationLink(destination: myProfile().environmentObject(userManager)
                    .environmentObject(authService)) {
                    Text("Manage Account")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
            }

            // Notifications Section
            Section(header: Text("Notifications")) {
                Toggle("Notifications", isOn: $notificationsEnabled)
                    .font(Font.custom("Orkney-Light", size: 17))
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue {
                            requestNotificationAuthorization()
                        } else {
                            unregisterFromNotifications()
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: skyBlueColor.skyBlue))
            }

            // Privacy Section
            Section(header: Text("Privacy Settings")) {
                /*
                NavigationLink(destination: privacyPolicy()
                    .environmentObject(UserManager())) {
                    Text("Privacy Settings")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
                */
                NavigationLink(destination: termsOfService()){ // Link to userFeedback view
                    Text("Terms of Service")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
            }

            // Security Section
            Section(header: Text("Security")) {
                /*
                NavigationLink(destination: mySecuritySettings(viewModel: ViewModel())
                    .environmentObject(UserManager())) {
                    Text("Security Settings")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
                 */
                Text("Security Settings")
                    .font(Font.custom("Orkney-Light", size: 17))
            }

            // Support Section
            Section(header: Text("Support")) {
                /*
                NavigationLink(destination: userSupportView()) {
                    Text("Help & Support")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
                
                NavigationLink(destination: userFeedback()) {
                    Text("Send Feedback")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
                 */
                NavigationLink(destination: userFeedback()
                    .environmentObject(authService)) { // Link to userFeedback view
                    Text("Feedback")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
                NavigationLink(destination: helpSupport()
                    .environmentObject(authService)) {
                    Text("Help & Support")
                        .font(Font.custom("Orkney-Light", size: 17))
                }
            }

            // Log Out Button
            Section {
                Button(action: {
                    //viewModel.signOut() // Call logOut from ViewModel
                    AuthService.shared.signOut()
                    print("Logged out Success")
                }) {
                    Text("Sign Out")
                        .foregroundColor(skyBlueColor.skyBlue)
                        .font(Font.custom("Orkney-Regular", size: 17))
                }
            }
            
            Section {
                NavigationLink(destination: deleteAccount(text: "")
                    .environmentObject(authService)) {
                    Text("Delete Account")
                        .foregroundColor(.red)
                        .font(Font.custom("Orkney-Bold", size: 17))
                }
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color.black)
                        .padding()
                }
            }
        }
        .onAppear {
                checkNotificationStatus()
            }
        .navigationDestination(isPresented: $deleteAccountStarted){
            deleteAccount(text: "")
                .environmentObject(authService)
        }
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification authorization granted")
            } else if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func unregisterFromNotifications() {
            DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
                self.notificationsEnabled = false
                print("Unregistered from notifications")
            }
        }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }
}


struct mySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        mySettings()
            .environmentObject(UserManager.shared)
            .environmentObject(AuthService())
    }
}


class NotificationManager: ObservableObject {
    @Published var notificationsEnabled: Bool = false
    
    init() {
        checkNotificationStatus()
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Notification authorization granted")
                    self.notificationsEnabled = true
                    UIApplication.shared.registerForRemoteNotifications()
                } else if let error = error {
                    print("Error requesting notification authorization: \(error.localizedDescription)")
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    func unregisterFromNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
            self.notificationsEnabled = false
            print("Unregistered from notifications")
        }
    }
}
