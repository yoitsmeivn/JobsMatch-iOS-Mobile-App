import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore



struct EmailVerificationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isCheckingEmail = false
    @State private var showResendButton = false
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    @State private var isCollapsing = false
    @State private var offset: CGFloat = 0
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
                    }
                
                VStack(spacing: -150) {
                    Image("WaveLogoWhite")
                        .resizable()
                        .frame(width: 275, height: 274, alignment: .center)
                        .padding()
                    VStack(spacing: 10) {
                        Spacer()
                        VStack(spacing:15){
                            Text("Verify your email to you Find your Dream Job")
                                .foregroundStyle(.black)
                                .font(Font.custom("helvetica-bold", size: 20))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical)
                        VStack(spacing: 15) {
                            Text("We sent a verification link to:")
                                .foregroundStyle(.black)
                                .font(Font.custom("helvetica", size: 18))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                            
                            if let email = Auth.auth().currentUser?.email {
                                Text(email)
                                    .foregroundStyle(.black)
                                    .font(Font.custom("helvetica-bold", size: 18))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            Text("Click the link in your email to verify your account")
                                .foregroundStyle(.black)
                                .font(Font.custom("helvetica", size: 18))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        
                        Button(action: checkEmailVerification) {
                            HStack {
                                Text("Check Verification")
                                    .foregroundStyle(.white)
                                    .font(Font.custom("helvetica-bold", size: 18))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                if isCheckingEmail {
                                    CustomLoadingView(color: skyBlueColor.skyBlue)
                                        .frame(width: 25, height: 25)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(skyBlueColor.skyBlue)
                            .cornerRadius(10)
                        }
                        .disabled(isCheckingEmail)
                        .padding(.horizontal)
                        
                        if showResendButton {
                            Button(action: resendVerificationEmail) {
                                Text(timeRemaining > 0 ? "Resend in \(timeRemaining)s" : "Resend verification email")
                                    .foregroundStyle(.black)
                                    .font(Font.custom("helvetica", size: 15))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .disabled(timeRemaining > 0)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .onAppear {
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if let error = error {
                                print("Error resending verification email: \(error)")
                                return
                            }
                            timeRemaining = 30
                        }
                        startResendTimer()
                    }
                }
                .offset(y: offset)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: offset)
            }
        }
    }
    
    private func startResendTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            showResendButton = true
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    private func checkEmailVerification() {
        isCheckingEmail = true
        let user = Auth.auth().currentUser
        user?.reload(completion: { error in
            if let error = error {
                print("Error reloading user: \(error)")
                print("❌ Error reloading user: \(error)")
                isCheckingEmail = false
                return
            }
            
            if user?.isEmailVerified == true {
                print("✅ Email is verified - starting collapse animation")
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    offset = -UIScreen.main.bounds.height
                }
                // Update Firestore
                if let userId = user?.uid {
                    let db = Firestore.firestore()
                    db.collection("jobseekers").document(userId).updateData([
                        "emailVerified": true
                    ]) { error in
                        isCheckingEmail = false
                        if error == nil {
                            authService.fetchCurrentUser(for: userId)
                        }
                    }
                }
            } else {
                print("❌ Email is not verified yet")
                isCheckingEmail = false
            }
        })
    }
    
    private func resendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { error in
            if let error = error {
                print("Error resending verification email: \(error)")
                return
            }
            timeRemaining = 30
        }
    }
}

#Preview {
    EmailVerificationView()
}


