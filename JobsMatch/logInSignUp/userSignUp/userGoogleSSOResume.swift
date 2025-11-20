//
//  userGoogleSSOResume.swift
//  JobsMatch
//
//  Created by ivans Android on 5/16/25.
//

import SwiftUI
import FirebaseStorage
import AppTrackingTransparency
import AdSupport
import FirebaseAuth
import FirebaseFirestore


struct userGoogleSSOResume: View {
    @State private var navigateToCompletionView = false
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = ViewModel()
    @EnvironmentObject var authService: AuthService
    @StateObject private var jwtManager = JWTManager.shared
    @State private var navigateToNextView = false
    @Environment(\.dismiss) private var dismiss
    @State private var showFireworkAnimation = false
    @State private var buttonCenter: CGPoint = .zero // Changed from screenCenter to buttonCenter
    
    @State private var resume: URL?
    @State private var presentImporter = false
    @State private var fileName = ""
    @State private var showNotification = false
    @State private var notificationMessage = ""
    @State private var checkingVerification = false
    @State private var isVerified = false
    @Environment(\.presentationMode) var presentationMode
    @State private var accountCreated = false
    @State private var showPrivacySheet = false
    @State private var isLoading = false
    
    var isFormValid: Bool {
        resume != nil
    }
    
    // Define the preference key to get button position
    struct ButtonPositionPreferenceKey: PreferenceKey {
        static var defaultValue: CGPoint = .zero
        
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            value = nextValue()
        }
    }
    
    private func handleSignUpError(_ error: Error) {
            DispatchQueue.main.async {
                self.isLoading = false
                self.notificationMessage = "Error Creating Account: \(error.localizedDescription)"
                self.showNotification = true
                
                print("DEBUG: Error during sign up: \(error.localizedDescription)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.showNotification = false
                    }
                }
            }
        }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                    VStack(spacing: 10) {
                        Spacer(minLength: 60)
                        
                        VStack(spacing: 12) {
                            Text("Upload Your Resume")
                                .font(Font.custom("helvetica-bold", size: 28))
                                .foregroundColor(.black)
                            
                            Text("Swipe To Apply with your Resume")
                                .font(Font.custom("helvetica", size: 16))
                                .foregroundColor(.black.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack {
                            Text("Upload Resume (PDF Only)")
                                .foregroundStyle(.black)
                                .font(Font.custom("helvetica-bold", size: 15))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top)
                            uploadResumeButton
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 30)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ButtonPositionPreferenceKey.self,
                                                      value: CGPoint(
                                                          x: geo.frame(in: .global).midX,
                                                          y: geo.frame(in: .global).midY
                                                      ))
                                    }
                                )
                        }
                        .padding()
                    }
                    
                    Image("arrow")
                        .resizable()
                        .frame(width: 200, height: 250)
                        .rotationEffect(.degrees(175))
                    
                    Button(action: {
                        saveUserData4()
                        navigateToNextView = true
                        contentViewModel.markAccountAsComplete()
                    }) {
                        Text("Complete")
                            .font(Font.custom("helvetica-bold", size: 18))
                            .opacity(3)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 40)
                            .background(Color.black.opacity(isFormValid ? 1.0 : 0.5))
                            .cornerRadius(10)
                            .padding()
                            .padding(.bottom)
                    }
                    .disabled(!isFormValid)
                    .navigationDestination(isPresented: $navigateToNextView) {
                        userPassword()
                    }
                }
                
                if showFireworkAnimation {
                    ResumeFireworkAnimation(
                        centerPoint: CGPoint(x: buttonCenter.x, y: buttonCenter.y - 50), // Shifted 50 points higher
                        isAnimating: $showFireworkAnimation
                    )
                    .allowsHitTesting(false)
                }
            }
            .onPreferenceChange(ButtonPositionPreferenceKey.self) { position in
                buttonCenter = position
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func saveUserData4() {
        if let resume = resume {
            do {
                let bookmarkData = try resume.bookmarkData(
                    options: .minimalBookmark,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                UserDefaults.standard.set(bookmarkData, forKey: "resume")
            } catch {
                print("Failed to create bookmark: \(error)")
            }
        }
    }
    
    private var uploadResumeButton: some View {
        Button(action: {
            presentImporter.toggle()
        }) {
            HStack {
                Image(systemName: resume != nil ? "checkmark" : "paperclip")
                Text(resume != nil ? fileName : "Attach Resume")
                    .font(Font.custom("helvetica", size: 15))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .foregroundColor(.black)
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 20).fill(.white).stroke(Color.black, lineWidth: 3))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .fileImporter(
            isPresented: $presentImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let file = files.first {
                    fileName = file.lastPathComponent
                    resume = file
                    
                    // Trigger animation after a slight delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            showFireworkAnimation = true
                        }
                    }
                    
                    guard file.startAccessingSecurityScopedResource() else {
                        print("Failed to access security-scoped resource")
                        return
                    }
                    
                    defer {
                        file.stopAccessingSecurityScopedResource()
                    }
                    
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsDirectory.appendingPathComponent(file.lastPathComponent)
                    
                    do {
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        
                        try FileManager.default.copyItem(at: file, to: destinationURL)
                        
                        fileName = file.lastPathComponent
                        resume = destinationURL
                        
                        UserDefaults.standard.set(destinationURL.path, forKey: "resumePath")
                        
                        let bookmarkData = try destinationURL.bookmarkData(
                            options: .minimalBookmark,
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil
                        )
                        UserDefaults.standard.set(bookmarkData, forKey: "resumeBookmark")
                        
                    } catch {
                        print("Error handling file: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
    }

    
    private func setExperience(userData: [String : Any], viewModel: ViewModel) -> [String : Any] {
        var userData = userData
        
        let validExperiences = viewModel.experience.filter {
            !$0.values.allSatisfy { value in value.isEmpty }
        }
        
        if validExperiences.isEmpty {
            userData["experience"] = []
        } else {
            userData["experience"] = validExperiences
        }
        
        return userData
    }
    
//MARK: UPLOADRESUMEGOOGLE
    
    
    func uploadResumeGoogle(for userId: String, completion: @escaping (String?) -> Void) {
        // 1. Check if the resume exists locally
        guard let resumePath = UserDefaults.standard.string(forKey: "resumePath") else {
            print("No resume path found")
            notificationMessage = "Resume Not Found, Please Return"
            showNotification = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showNotification = false
                }
            }
            completion(nil)
            return
        }
        
        let resumeURL: URL
        if resumePath.hasPrefix("file://") {
            guard let fileURL = URL(string: resumePath) else {
                print("Invalid file URL string")
                notificationMessage = "Resume Not Found, Please Return"
                showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showNotification = false
                    }
                }
                completion(nil)
                return
            }
            resumeURL = fileURL
        } else {
            resumeURL = URL(fileURLWithPath: resumePath)
        }
        
        guard FileManager.default.fileExists(atPath: resumePath) else {
            print("File doesn't exist at path: \(resumePath)")
            completion(nil)
            return
        }

        // 2. Create a URL for the local resume file
        let fileName = resumeURL.lastPathComponent

        // 3. Upload to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference().child("resumes/\(userId)/\(fileName)")

        storageRef.putFile(from: resumeURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading to Firebase Storage: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // 4. Get the download URL
            // Fix for the new API that returns Result<URL, Error> instead of (URL?, Error?)
            storageRef.downloadURL { result in
                switch result {
                case .success(let downloadURL):
                    let urlString = downloadURL.absoluteString
                    UserDefaults.standard.set(urlString, forKey: "resume")
                    UserDataManager.saveResume(urlString)

                    // 5. Upload to FastAPI Docker
                    self.uploadToFastAPIGoogle(fileURL: resumeURL, userId: userId, firebaseURL: urlString) { result in
                        switch result {
                        case .success:
                            print("Successfully uploaded to FastAPI")
                            completion(urlString)
                            
                        case .failure(let error):
                            print("Failed to upload to FastAPI: \(error.localizedDescription)")
                            // Handle specific error cases if needed
                            if let jwtError = error as? JWTManager.JWTError {
                                switch jwtError {
                                case .expired:
                                    print("JWT Token expired - user needs to re-authenticate")
                                case .invalidToken:
                                    print("Invalid JWT Token")
                                case .encodingFailed:
                                    print("JWT encoding failed")
                                }
                            }
                            completion(nil)
                        }
                    }
                    
                case .failure(let error):
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
    
    func uploadToFastAPIGoogle(fileURL: URL, userId: String, firebaseURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let apiURL = URL(string: "https://jobsmatch.io/api/jobseekers/embedResume") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        guard FileManager.default.fileExists(atPath: fileURL.path),
              let resumeData = try? Data(contentsOf: fileURL) else {
            completion(.failure(URLError(.fileDoesNotExist)))
            return
        }

        // Get and validate JWT token
        guard let jwtToken = JWTManager.shared.getToken() else {
            completion(.failure(JWTManager.JWTError.invalidToken))
            return
        }
        
        if let token = JWTManager.shared.getToken() {
            print("\n=== Token Debug Info ===")
            JWTManager.shared.debugToken(token)
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        
        // Ensure proper Bearer token format
        let authHeader = "Bearer \(jwtToken)".trimmingCharacters(in: .whitespaces)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let boundary = userId // Use a unique boundary
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add resume file to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"resume\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
        body.append(resumeData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body

        // Add debug logging
        print("Request Body Structure:")
        if let bodyString = String(data: body, encoding: .utf8) {
            print(bodyString)
        }
        
        // Add metadata
        let metadata = [
            "user_id": userId,
            "firebase_url": firebaseURL
        ]
        
        for (key, value) in metadata {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        

        // Debug logging
        print("🔐 Request Details:")
        print("URL:", request.url?.absoluteString ?? "")
        print("Headers:", request.allHTTPHeaderFields ?? [:])
        print("User ID:", userId)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            // Enhanced error handling
            if httpResponse.statusCode == 403 {
                print("⛔️ Authentication Failed (403):")
                print("Response Headers:", httpResponse.allHeaderFields)
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Error Response:", errorResponse)
                }
                
                // Check if token is expired and try to refresh
                if JWTManager.shared.isTokenExpired(jwtToken) {
                    JWTManager.shared.clearToken() // Clear invalid token
                }
                
                completion(.failure(JWTManager.JWTError.expired))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    completion(.failure(NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse])))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            completion(.success(()))
            contentViewModel.hasFinishedUploadingResume = true
            contentViewModel.isSigningUp = false
        }
        
        task.resume()
    }

    func signUpGoogle(email: String, password: String, full_name: String) {
        let customUserId = UUID().uuidString
        UserDefaults.standard.set(customUserId, forKey: "user_uuid")
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if let error = error {
                notificationMessage = "Error Creating Account, Please Return"
                print("error message 1")
                print("DEBUG error creating an account: \(error.localizedDescription)")
                print("DEBUG 2 error creating an account: \(error)")
                showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showNotification = false
                    }
                }
                return
            }
            
            guard (authResult?.user) != nil else {
                notificationMessage = "Error Creating Account, Please Return"
                print("error message 2")
                showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showNotification = false
                    }
                }
                return
            }
            guard let user = authResult?.user else { return }
            // Save additional user information to Firestore
            
            JWTManager.shared.generateJWTToken(userId: customUserId, email: email) { result in
                switch result {
                case .success(let token):
                    // Save the JWT token
                    JWTManager.shared.saveToken(token)
                    print(token)
                    self.uploadResumeGoogle(for: customUserId) { downloadURL in
                        guard let resumeURL = downloadURL else {
                            // Handle error
                            print("Failed to upload resume")
                            return
                        }
                        let db = Firestore.firestore()
                        
                        var userData: [String: Any] = [
                            "full_name": full_name,
                            "email": email,
                            "address": viewModel.address,
                            "education": viewModel.education,
                            "work_eligibility": viewModel.work_eligibility,
                            "disability_status" : viewModel.disability_status,
                            "military_status" : viewModel.military_status,
                            "jobs_applied": viewModel.jobs_applied,
                            "resume": resumeURL
                        ]
                        
                        userData = setExperience(userData: userData, viewModel: viewModel)
                        
                        db.collection("jobseekers").document(customUserId).setData(userData){ error in
                            if let error = error {
                                print("DEBUG: ERROR SIGNING UP\(error)")
                                print("error message 3")
                                notificationMessage = "Error Creating Account, Please Return"
                                showNotification = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showNotification = false
                                    }
                                }
                            } else {
                                
                                self.authService.userSession = user
                                self.authService.fetchCurrentUser(for: customUserId)
                                SendbirdManager.shared.connectUser(authService: authService)
                                
                                DispatchQueue.main.async {
                                    navigateToCompletionView = true
                                }
                                
                            }
                        }
                    }
                    case .failure(let error):
                        print("Failed to generate JWT token: \(error)")
                        self.handleSignUpError(error)
                    }
            }
        }
    }
}

#Preview {
    userGoogleSSOResume()
}
