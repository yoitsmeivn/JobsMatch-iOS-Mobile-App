//
//  forgotAccountView.swift
//  JobsMatch
//
//  Created by ivans Android on 6/21/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var isLoading = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    func sendResetLink() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email address"
            showAlert = true
            return
        }
        
        // Start loading state
        isLoading = true
        
        // Send password reset email using Firebase
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            // Execute on main thread since we're updating UI
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    // Handle specific Firebase errors
                    switch error.localizedDescription {
                    case let str where str.contains("no user record"):
                        alertMessage = "No account found with this email address"
                    case let str where str.contains("invalid email"):
                        alertMessage = "Please enter a valid email address"
                    default:
                        alertMessage = "An error occurred. Please try again later"
                    }
                    isSuccess = false
                } else {
                    // Success case
                    alertMessage = "Password reset link has been sent to your email"
                    isSuccess = true
                    
                    // Optional: Log the password reset attempt
                    let db = Firestore.firestore()
                    db.collection("passwordResetLogs").addDocument(data: [
                        "email": email,
                        "timestamp": FieldValue.serverTimestamp(),
                        "success": true
                    ]) { err in
                        if let err = err {
                            print("Error logging password reset: \(err)")
                        }
                    }
                }
                showAlert = true
            }
        }
    }
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    var body: some View {
        ZStack {
            skyBlueColor.skyBlue
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
                }
            
            VStack(spacing: 20) {
                HStack {
                    Image("JobsMatchBluebackground")
                        .resizable()
                        .frame(width: 200, height: 55)
                        .padding(.bottom)
                    Spacer()
                }
                .padding()
                
                Spacer()
                Spacer()
                Text("Reset Password")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(Font.custom("orkney-bold", size: 24))
                
                Text("Enter your email address and we'll send you a link to reset your password")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(Font.custom("orkney-bold", size: 16))
                    .padding(.horizontal)
                
                TextField("Enter your Email",text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(6.0)
                    .padding(.horizontal,35)
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                    .keyboardType(.emailAddress)
                    .onChange(of: email) { newValue in
                        // Optional: Clear any previous error messages when user starts typing
                        if showAlert {
                            showAlert = false
                        }
                    }
                Spacer()
                Spacer()
                Button(action: {
                    if isValidEmail(email) {
                        sendResetLink()
                    } else {
                        alertMessage = "Please enter a valid email address"
                        showAlert = true
                    }
                }) {
                    if isLoading {
                        CustomLoadingView(color: skyBlueColor.skyBlue)
                            .frame(width: 25, height: 25)
                    } else {
                        Text("Send Reset Link")
                            .font(Font.custom("Orkney-Bold", size: 18))
                            .opacity(3)
                            .foregroundColor(skyBlueColor.skyBlue)
                            .frame(width: 300, height: 40)
                            .background(Color.black.opacity(isValidEmail(email) ? 1.0 : 0.5))
                            .cornerRadius(10)
                    }
                }
                .disabled(email.isEmpty || isLoading)
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Back to Login")
                        .font(Font.custom("Orkney-Bold", size: 18))
                        .foregroundColor(.black)
                }
                .padding(.bottom)
                
            }
        }
        .alert(isSuccess ? "Success" : "Error", isPresented: $showAlert) {
            Button(isSuccess ? "OK" : "Try Again", role: .cancel) {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ForgotPasswordView()
}
