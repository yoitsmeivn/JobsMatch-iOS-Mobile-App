//
//  ContentView.swift
//  JobsMatch
//
//  Created by ivans Android on 3/24/24.
//

import SwiftUI
import FirebaseAuth

class ContentViewModel: ObservableObject {
    
    @Published var hasFinishedUploadingResume = false
    @Published var isSigningUp = false
    
    @Published var accountIsSet: Bool {
            didSet {
                UserDefaults.standard.set(accountIsSet, forKey: "accountIsSet")
            }
        }
        
        init() {
            // Initialize from UserDefaults (defaults to false for new users)
            self.accountIsSet = UserDefaults.standard.bool(forKey: "accountIsSet")
        }
        
        // Call this when account setup is fully complete
        func markAccountAsComplete() {
            accountIsSet = true
        }
        
        // Call this to reset account setup (for debugging or logout)
        func resetAccountSetup() {
            accountIsSet = false
        }
}

struct ContentView: View {
    
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var authServiceHost: AuthServiceHost
    @StateObject var userManager = UserManager.shared
    @StateObject var sendbirdManager = SendbirdManager.shared
    @State private var showImage: Bool = false
    
    @StateObject private var viewModel = ContentViewModel()
    
    private var _logInView: some View {
        logInSelectionView()
            .environmentObject(AuthService())
            .environmentObject(AuthServiceHost())
            .environmentObject(ContentViewModel())
    }
    
    var body: some View {
        ZStack {
            if showImage {
                Image("WaveJustLogoWhite")
                    .resizable()
                    .frame(width: 250, height: 210, alignment: .center)
            } else {
                if !viewModel.isSigningUp{
                    if let userSession = authService.userSession {
                        if viewModel.accountIsSet {
                            Home()
                                .environmentObject(userManager)
                                .onAppear {
                                    sendbirdManager.connectUser(authService: authService)
                                    print("made it to home")
                                    if let uuid = UserDefaults.standard.string(forKey: "userUUID"){
                                        if let email = UserDefaults.standard.string(forKey: "email"){
                                            JWTManager.shared.generateJWTToken(userId: uuid, email: email) { result in
                                                switch result {
                                                case .success(let token):
                                                    // Save the JWT token
                                                    JWTManager.shared.saveToken(token)
                                                    print(token)
                                                case .failure(_):
                                                    return
                                                }
                                            }
                                        }
                                    }
                                }
                            if !userSession.isEmailVerified {
                                EmailVerificationView()
                                    .environmentObject(authService)
                            }
                        } else {
                            _logInView
                        }
                    } else {
                        _logInView
                    }
                } else {
                    _logInView
                }
                
            }
        }
        .onAppear {
            authService.listenToAuthState()
            authServiceHost.listenToAuthStateHost()
            updateViewState()
        }
    }
    
    private func updateViewState() {
        if authService.userSession == nil && authServiceHost.hostSession == nil {
            print("user is nil")
            showImage = true
        } else {
            showImage = false
            print("setting showImage to false")
        }
        
        if showImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showImage = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
        .environmentObject(AuthServiceHost.shared)
}
