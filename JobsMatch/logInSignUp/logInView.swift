//
//  logInView.swift
//  JobsMatch
//
//  Created by ivans Android on 3/26/24.
//

import Firebase
import FirebaseAuth
import SwiftUI
import GoogleSignIn

struct logInView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var authServiceHost: AuthServiceHost
    @State private var adminLoggedin: Bool = false
    @State private var email = ""
    @State private var password = ""
    @State var invalidEmail = 0
    @State var invalidPassword = 0
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var shakeEffectTriggerEmail = false
    @State private var shakeEffectTriggerPassword = false
    @State private var isLoading = false
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
                    }
                
                VStack(spacing: -50) {
                    Image("WaveLogoWhite")
                        .resizable()
                        .frame(width: 275, height: 274, alignment: .center)
                        .padding()
                    
                    VStack(spacing: 12) {
                        Spacer(minLength: 90)
                        Text("Welcome Back")
                            .font(Font.custom("helvetica-bold", size: 20))
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .font(Font.custom("helvetica", size: 14))
                            .padding(.horizontal, 12)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(invalidEmail == 0 ? Color.gray : Color.red)
                            )
                            .padding(.horizontal, 35)
                            .modifier(
                                shakeEffect(animatableData: CGFloat(shakeEffectTriggerEmail ? 1 : 0))
                            )

                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .font(Font.custom("helvetica", size: 14))
                            .padding(.horizontal, 12)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(invalidPassword == 0 ? Color.gray : Color.red)
                            )
                            .padding(.horizontal, 35)
                            .modifier(
                                shakeEffect(animatableData: CGFloat(shakeEffectTriggerPassword ? 1 : 0))
                            )
                        NavigationLink {
                            ForgotPasswordView()
                        } label: {
                            Text("Forgot Account?")
                                .font(Font.custom("helvetica-bold", size: 16))
                                .foregroundColor(.black)
                        }
                        VStack(spacing:0){
                            dividerWithLabel(label: "or")
                            Button(action: googleLogin) {
                                    HStack {
                                        Image(systemName: "g.circle.fill")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text("Sign in with Google")
                                            .font(Font.custom("helvetica-bold", size: 14))
                                            .foregroundColor(.black)  // Adjust text color as needed
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding() // Padding inside the button
                                }
                                .background(
                                    // White rounded rectangle as background for the button
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(lineWidth: 0.5)
                                        .fill(Color.black)
                                )
                                .padding(.horizontal, 35)
                        }
                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(Font.custom("helvetica", size: 12))
                        }
                        Spacer()
                        if isLoading {
                            CustomLoadingView(color: skyBlueColor.skyBlue)
                                .frame(width: 35, height: 35)
                        }
                    }
                    
                    VStack(spacing: 15) {
                        Spacer()
                        Button(action: {
                            print("login button pressed")
                            Task {
                                loginUser()
                                contentViewModel.markAccountAsComplete()
                            }
                        }) {
                            Text("Log In")
                                .font(Font.custom("helvetica-bold", size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2)
                                        .frame(width: 330, height: 40)
                                )
                        }
                        .padding(.top,20)
                        
                        Button(action: { dismiss() }) {
                            Text("Sign Up Free Today")
                                .font(Font.custom("helvetica-bold", size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.top, 0)
                    }
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationDestination(isPresented: $isLoggedIn) {
            Home()
        }
        .navigationDestination(isPresented: $adminLoggedin) {
            hostHome()
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)
        .onAppear{
            contentViewModel.isSigningUp = true
        }
    }
    
    func loginUser() {
        print("loginUser called with email: \(email) and password: \(password)")
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            self.isLoading = false
            
            if let error = error {
                print("Error during authorization: \(error.localizedDescription)")
                self.errorMessage = "Invalid Email or Password"
                self.showError = true
                self.invalidEmail += 1
                self.invalidPassword += 1
                withAnimation(.default) {
                    self.shakeEffectTriggerEmail.toggle()
                    self.shakeEffectTriggerPassword.toggle()
                }
                return
            }
            
            if let user = authResult?.user {
                let db = Firestore.firestore()
                print("DEBUG: Successfully signed in with Firebase Auth")
                print("DEBUG: Checking if user is recruiter or jobseeker")
                
                db.collection("jobseekers")
                    .whereField("email", isEqualTo: user.email ?? "")
                    .getDocuments { (snapshot, error) in
                        if let error = error {
                            print("DEBUG: Error finding jobseeker: \(error)")
                            return
                        }
                        
                        if let document = snapshot?.documents.first {
                            let uuid = document.documentID
                            print("DEBUG: Found jobseeker with UUID: \(uuid)")
                            
                            // Store the UUID for future use
                            UserDefaults.standard.set(uuid, forKey: "userUUID")
                            
                            DispatchQueue.main.async {
                                print("DEBUG: Setting auth states")
                                self.authServiceHost.hostSession = nil
                                self.authService.userSession = user
                                print("DEBUG: Fetching current user")
                                self.authService.fetchCurrentUser(for: uuid)
                                print("DEBUG: Setting isLoggedIn to true")
                                self.isLoggedIn = true
                                print("DEBUG: isLoggedIn is now \(self.isLoggedIn)")
                                
                                // Force a view update
                                contentViewModel.isSigningUp = false
                            }
                        } else {
                            print("DEBUG: No jobseeker document found for email: \(user.email ?? "")")
                        }
                    }
            }
        }
    }
    func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    }
}

struct shakeEffect: GeometryEffect {
    var amount: CGFloat = 6
    var shakesPerUnit = 4
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX:
                    amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
    }
}

#Preview {
    logInView()
        .environmentObject(AuthService())
        .environmentObject(AuthServiceHost())
        .environmentObject(ContentViewModel())
}


