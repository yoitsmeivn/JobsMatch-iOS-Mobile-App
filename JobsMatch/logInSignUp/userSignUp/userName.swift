import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase
import FirebaseCore
import FirebaseFirestore



struct userName: View {
    @State var firstName = ""
    @State var lastName = ""
    @State var full_name = ""
    @State var email = ""
    @State private var fnameSelected = false
    @State private var lNameSelected = false
    @State private var emailSelected = false
    @State private var navigateToNextView = false
    @State private var navigateToGoogleSSOView = false // New state variable for Google SSO navigation
    @State private var gender: String? = nil
    @State private var pronouns: String? = nil
    @State private var isLoading = false
    @State private var emailExists = false
    @State private var emailCheckPerformed = false
    @State private var emailError: String? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToJobFilter = false
    
    @State private var showNotification = false
    @State private var notificationMessage = ""
    
    @State private var isValidatingEmail = false
    @State private var emailValidationError: String? = nil
    
    
    @Environment(\.dismiss) private var dismiss
    
    let emailRegex = """
            ^(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$
            """
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !isValidatingEmail &&
        emailValidationError == nil
    }
    var body: some View {
        VStack{
                VStack(spacing: 3){
                    ZStack {
                    // HStack for the dismiss button aligned to the left
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundColor(.black)
                                .padding()
                        }
                        Spacer() // This pushes the button to the left
                    }
                    // Centered image
                    Image("WaveJustLogoWhite")
                        .resizable()
                        .frame(width: 150, height: 125)
                        .padding(.top)
                }
                .padding(.bottom)
                VStack(spacing:-20){
                    Text("Create Your Account")
                        .foregroundStyle(.black)
                        .font(Font.custom("helvetica-bold", size: 25))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .padding(.top,-10)
                    Text("Own your job search—personalize, apply, and connect.")
                        .foregroundStyle(.black)
                        .font(Font.custom("helvetica", size: 16))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        
                }
                VStack(spacing: 11){
                    Text("First Name")
                        .foregroundStyle(.black)
                        .font(Font.custom("helvetica-bold", size: 13))
                        .padding(.horizontal,35)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    TextField("Enter your First Name",text: $firstName)
                        .disableAutocorrection(true)
                        .font(Font.custom("helvetica", size: 12))
                        .padding(.horizontal, 12)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color.gray)
                        )
                        .padding(.horizontal,35)
                    Text("Last Name")
                        .foregroundStyle(.black)
                        .font(Font.custom("helvetica-bold", size: 13))
                        .padding(.horizontal,35)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    TextField("Enter your Last Name",text: $lastName)
                        .disableAutocorrection(true)
                        .font(Font.custom("helvetica", size: 12))
                        .padding(.horizontal, 12)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color.gray)
                        )
                        .padding(.horizontal,35)
                    Text("Email")
                        .foregroundStyle(.black)
                        .font(Font.custom("helvetica-bold", size: 13))
                        .padding(.horizontal,35)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    TextField("Enter your Email",text: $email)
                        .disableAutocorrection(true)
                        .font(Font.custom("helvetica", size: 12))
                        .padding(.horizontal, 12)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color.gray)
                        )
                        .padding(.horizontal,35)
                }
                .padding()
                    /*
                Text("Gender")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 13))
                    .padding(.horizontal,35)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding()
                HStack {
                   GenderButton(title: "Female", gender: $gender)
                   GenderButton(title: "Male", gender: $gender)
                   GenderButton(title: "Other", gender: $gender)
               }
               .padding(.horizontal, 35)
               .padding(.vertical, 6)
                Text("Pronouns")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 13))
                    .padding(.horizontal,35)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding()
                HStack {
                    PronounsButton(title: "She/Her", pronouns: $pronouns)
                    PronounsButton(title: "He/Him", pronouns: $pronouns)
                    PronounsButton(title: "They/Them", pronouns: $pronouns)
                    PronounsButton(title: "Other", pronouns: $pronouns)
               }
               .padding(.horizontal, 35)
               .padding(.vertical, 6)
                     */
                    
                    VStack(spacing:15){
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
                Spacer()
                Button(action: {
                    isLoading = true
                    
                    // Set full_name by combining firstName and lastName
                    full_name = "\(firstName) \(lastName)"
                                        
                    if isValidEmail(email) {
                        checkEmailExistence()
                    } else {
                        notificationMessage = "Invalid Email Address"
                        withAnimation {
                            showNotification = true
                        }
                        
                        // Hide notification after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showNotification = false
                            }
                        }
                        isLoading = false
                    }
                }) {
                    ZStack {
                        Text(isLoading ? "" : "Continue")
                            .font(Font.custom("Orkney-Bold", size: 18))
                            .opacity(3)
                            .foregroundColor(Color.white)
                            .frame(width: 300, height: 40)
                            .background(Color.black.opacity(isFormValid ? 1.0 : 0.5))
                            .cornerRadius(10)
                        
                        if isLoading {
                            CustomLoadingView(color: skyBlueColor.skyBlue)
                                .frame(width: 25, height: 25)
                        }
                    }
                    .padding()
                }
                .disabled(!isFormValid || isLoading)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                // Normal sign up navigation
                .navigationDestination(isPresented: $navigateToNextView) {
                    userSoloResume()
                }
                // Google SSO navigation
                .navigationDestination(isPresented: $navigateToGoogleSSOView) {
                    userGoogleSSOResume()
                }
            }
            if showNotification {
                VStack {
                    Spacer()
                    NotificationView2(message: notificationMessage)
                        .transition(.move(edge: .top))
                }
                .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
        }
    }
    var areFieldsFilled: Bool {
            !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
        }
    
    func saveUserData1() {
        // Set full_name if not already set
        if full_name.isEmpty {
            full_name = "\(firstName) \(lastName)"
        }
        
        UserDefaults.standard.set(full_name, forKey: "full_name")
        UserDefaults.standard.set(email, forKey: "email")
    }
    
    func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard trimmedEmail == email, // No whitespace
                  !email.contains(".."), // No consecutive dots
                  email.count <= 254,    // Length check
                  email.split(separator: "@").count == 2 // One @ symbol
            else {
                return false
            }
            
            return emailPred.evaluate(with: email)
        }
    
    func googleLogin() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            isLoading = false
            showAlert = true
            alertMessage = "Firebase configuration error"
            return
        }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isLoading = false
            showAlert = true
            alertMessage = "Cannot present Google Sign In"
            return
        }
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                isLoading = false
                showAlert = true
                alertMessage = "Sign in error: \(error.localizedDescription)"
                return
            }
            
            guard let user = result?.user,
                  let profile = user.profile else {
                isLoading = false
                showAlert = true
                alertMessage = "Could not get user profile"
                return
            }
            
            // Get user details from Google profile
            firstName = profile.givenName ?? ""
            lastName = profile.familyName ?? ""
            email = profile.email
            
            // Set full_name by combining firstName and lastName from Google profile
            full_name = "\(firstName) \(lastName)"
            
            // Authenticate with Firebase
            guard let idToken = user.idToken else {
                isLoading = false
                showAlert = true
                alertMessage = "Failed to get authentication token"
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { _, error in
                isLoading = false
                
                if let error = error {
                    showAlert = true
                    alertMessage = "Firebase authentication error: \(error.localizedDescription)"
                    return
                }
                
                // Validate filled fields
                if firstName.isEmpty || lastName.isEmpty || email.isEmpty {
                    notificationMessage = "Could not get all required information from Google"
                    withAnimation {
                        showNotification = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showNotification = false
                        }
                    }
                    return
                }
                
                // Save user data
                saveUserData1()
                
                // Navigate directly to the Google SSO resume view
                navigateToGoogleSSOView = true
            }
        }
    }
        
    // Simplified email existence check
    func checkEmailExistence() {
        isLoading = true
        isValidatingEmail = true
        
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Validate email format first
        guard isValidEmail(sanitizedEmail) else {
            isLoading = false
            isValidatingEmail = false
            notificationMessage = "Please enter a valid email address"
            showNotification = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showNotification = false
                }
            }
            return
        }
        
        // Check only in jobseekers collection
        let db = Firestore.firestore()
        db.collection("jobseekers")
            .whereField("email", isEqualTo: sanitizedEmail)
            .getDocuments { (querySnapshot, error) in
                isLoading = false
                isValidatingEmail = false
                
                if error != nil {
                    notificationMessage = "Error checking email. Please try again."
                    showNotification = true
                } else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                    notificationMessage = "This email is already in use. Please use another one."
                    showNotification = true
                } else {
                    // Email is valid and doesn't exist
                    saveUserData1()
                    // For regular sign up, navigate to the regular resume view
                    navigateToNextView = true
                    return
                }
                
                // Hide notification after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showNotification = false
                    }
                }
            }
    }
    
}


struct GenderButton: View {
    let title: String
    @Binding var gender: String?
    
    var body: some View {
        Button(action: {
            gender = title
        }) {
            Text(title)
                .font(Font.custom("Orkney-Regular", size: 12))
                .padding()
                .background(gender == title ? skyBlueColor.skyBlue : Color.white)
                .foregroundColor(gender == title ? Color.black : Color.black)
                .cornerRadius(10.0)
                .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
        }
    }
}

struct PronounsButton: View {
    let title: String
    @Binding var pronouns: String?
    
    var body: some View {
        Button(action: {
            pronouns = title
        }) {
            Text(title)
                .font(Font.custom("Orkney-Regular", size: 10))
                .padding()
                .background(pronouns == title ? skyBlueColor.skyBlue : Color.white)
                .foregroundColor(pronouns == title ? Color.black : Color.black)
                .cornerRadius(10.0)
                .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
        }
    }
}


struct NotificationView2: View {
    let message: String
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkStrokeEnd: CGFloat = 0
    
    var body: some View {
        HStack {
            Text(message)
                .font(Font.custom("Orkney-Light", size: 15))
                .foregroundColor(skyBlueColor.skyBlue)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}



#Preview {
    userName()
}
