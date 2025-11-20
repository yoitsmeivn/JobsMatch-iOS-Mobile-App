//
//  hostSettings.swift
//  JobsMatch
//
//  Created by ivans Android on 5/22/24.
//


import SwiftUI

struct hostSettings: View {
    @State private var email: String = "user@example.com"
    @State private var password: String = "••••••••"
    @State private var username: String = "User123"
    @State private var notificationsEnabled: Bool = true
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
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
                            Text("")
                                .font(Font.custom("Orkney-Bold", size: 17))
                            Text("")
                                .font(Font.custom("Orkney-Light", size: 17))
                            Text("")
                                .foregroundColor(.gray)
                                .font(Font.custom("Orkney-Light", size: 17))
                        }
                    }
                    NavigationLink(destination: AccountManagementView()) {
                        Text("Manage Account")
                            .font(Font.custom("Orkney-Light", size: 17))
                    }
                }
                
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Notifications")
                            .font(Font.custom("Orkney-Light", size: 17))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: skyBlueColor.skyBlue))
                }
                
                
                // Privacy Section
                Section(header: Text("Privacy")) {
                    NavigationLink(destination: PrivacySettingsView()) {
                        Text("Privacy Settings")
                            .font(Font.custom("Orkney-Light", size: 17))
                    }
                }
                
                // Security Section
                Section(header: Text("Security")) {
                    NavigationLink(destination: SecuritySettingsView()) {
                        Text("Security Settings")
                            .font(Font.custom("Orkney-Light", size: 17))
                    }
                }
                
                
                // Support Section
                Section(header: Text("Support")) {
                    NavigationLink(destination: SupportView()) {
                        Text("Help & Support")
                            .font(Font.custom("Orkney-Light", size: 17))
                    }
                    NavigationLink(destination: FeedbackView()) {
                        Text("Send Feedback")
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
                        Text("Log Out")
                            .foregroundColor(.red)
                            .font(Font.custom("Orkney-Light", size: 17))
                    }
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: { dismiss() }) {
                        Image(systemName:"chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color.black)
                            .padding()
                    }
                }
            }
        }
    }
}

// Placeholder views for navigation links
struct AccountManagementView: View {
    var body: some View {
        Text("Manage your account here.")
            .navigationBarTitle("Account Management")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("Adjust your privacy settings here.")
            .navigationBarTitle("Privacy Settings")
    }
}

struct SecuritySettingsView: View {
    var body: some View {
        Text("Adjust your security settings here.")
            .navigationBarTitle("Security Settings")
    }
}

struct AppPreferencesView: View {
    var body: some View {
        Text("Adjust your app preferences here.")
            .navigationBarTitle("App Preferences")
    }
}

struct SupportView: View {
    var body: some View {
        Text("Find help and support here.")
            .navigationBarTitle("Help & Support")
    }
}

struct FeedbackView: View {
    var body: some View {
        Text("Send us your feedback here.")
            .navigationBarTitle("Send Feedback")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        hostSettings()
            .environmentObject(AuthService())
    }
}


