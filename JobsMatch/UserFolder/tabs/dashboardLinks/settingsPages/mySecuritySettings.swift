//
//  mySecuritySettings.swift
//  JobsMatch
//
//  Created by ivans Android on 7/10/24.
//

import SwiftUI

struct mySecuritySettings: View {
    @StateObject var userManager = UserManager.shared
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    // State variables for picker selections
    @State private var twoFactorAuthSelection = "No"
    @State private var passwordManagementSelection = "No"
    @State private var loginActivitySelection = "No"
    @State private var securityQuestionsSelection = "No"
    @State private var deviceManagementSelection = "No"
    @State private var accountRecoverySelection = "No"
    @State private var biometricSettingsSelection = "No"
    @State private var securityAlertsSelection = "No"
    
    // Picker options
    private let options = ["Yes", "No", "Maybe"]

    var body: some View {
        ScrollView {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName:"chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color.black)
                        .padding()
                }
                Spacer()
            }
            Text("Your Security Settings")
                .font(Font.custom("Orkney-Bold", size: 30))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            VStack(spacing: 20) {
                SecuritySection(title: "Two-Factor Authentication (2FA)", description: "Enable or disable two-factor authentication.", selection: $twoFactorAuthSelection, options: options)
                SecuritySection(title: "Password Management", description: "Change your password and manage password settings.", selection: $passwordManagementSelection, options: options)
                SecuritySection(title: "Login Activity", description: "View recent login activity and log out of all sessions.", selection: $loginActivitySelection, options: options)
                SecuritySection(title: "Account Recovery Options", description: "Add or update recovery email and phone number.", selection: $accountRecoverySelection, options: options)
                SecuritySection(title: "Security Alerts", description: "Enable or disable security-related notifications.", selection: $securityAlertsSelection, options: options)
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
}

struct SecuritySection: View {
    let title: String
    let description: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(Font.custom("Orkney-Bold", size: 20))
                .foregroundColor(.black)
            Text(description)
                .font(Font.custom("Orkney-Regular", size: 16))
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            Picker(selection: $selection, label: Text("Select an option")) {
                ForEach(options, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(skyBlueColor.skyBlue) // Change this color to whatever you prefer
            Divider()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

#Preview {
    mySecuritySettings(viewModel: ViewModel())
        .environmentObject(UserManager())
}
