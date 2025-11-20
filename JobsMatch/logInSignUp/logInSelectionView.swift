//
//  logInSelectionView.swift
//  JobsMatch
//
//  Created by ivans Android on 2/6/25.
//

import SwiftUI

struct logInSelectionView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var authServiceHost: AuthServiceHost
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    @State private var navigateToLogin = false
    @State private var navigateToSignUp = false
    @StateObject private var viewModel = ContentViewModel()

    
    
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.white
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
                    }
                
                VStack(spacing: -5) {
                    // Logo at the top.
                    Image("WaveLogoWhite")
                        .resizable()
                        .frame(width: 275, height: 274, alignment: .center)
                        .padding()
                    
                    
                    Spacer()
                    
                    NavigationLink {
                        logInView()
                            .environmentObject(authService)
                            .environmentObject(authServiceHost)
                            .environmentObject(viewModel)
                    } label: {
                        Text("Log In")
                            .font(Font.custom("helvetica-bold", size: 16))
                            .foregroundColor(.black)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 330, height: 50)
                            )
                    }
                    .padding(.top, 20)
                    
                    NavigationLink {
                        userName()
                    } label: {
                        Text("Sign Up")
                            .font(Font.custom("helvetica-bold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 330, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    logInSelectionView()
        .environmentObject(AuthService())
        .environmentObject(AuthServiceHost())
        .environmentObject(ContentViewModel())
}
