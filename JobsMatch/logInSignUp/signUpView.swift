//
//  singUpView.swift
//  JobsMatch
//
//  Created by ivans Android on 3/26/24.
//

import SwiftUI

struct signUpView: View {
    @State private var userSelected = true
    @State private var hostSelected = true
    @Environment(\.dismiss) private var dismiss
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
                VStack{
                    Text("Welcome")
                        .font(Font.custom("helvetica-bold", size: 28))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    Text("Reinventing the Job Application for ")
                        .font(Font.custom("helvetica", size: 20))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("Everybody")
                        .font(Font.custom("helvetica", size: 20))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.bottom,60)
                Text("Select Account Type")
                        .font(Font.custom("helvetica", size: 18))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top,20)
                HStack(spacing: 80){
                    Button(action: {
                        if userSelected {
                            hostSelected.toggle()
                        } else {
                            userSelected.toggle()
                            hostSelected.toggle()
                        }
                    }) {
                        Text("Job Seeker")
                            .font(Font.custom("helvetica", size: 18))
                            .foregroundColor(hostSelected ? .black : skyBlueColor.skyBlue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(hostSelected ? Color.black : Color.black, lineWidth: 3)
                                    .frame(width: 125, height: 150)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 125, height: 150)
                                    .foregroundColor(hostSelected ? Color.clear : skyBlueColor.skyBlue)
                            )
                            .overlay(
                                withAnimation{
                                    VStack(spacing: 5){
                                        Text("Job Seeker")
                                            .font(Font.custom("helvetica", size: 18))
                                            .foregroundColor(hostSelected ? .clear : .black)
                                        Spacer()
                                        Text("Swipe to")
                                            .font(Font.custom("helvetica", size: 14))
                                            .foregroundColor(hostSelected ? .clear : .black)
                                        Text("Find Your")
                                            .font(Font.custom("helvetica", size: 14))
                                            .foregroundColor(hostSelected ? .clear : .black)
                                        Text("Dream Job")
                                            .font(Font.custom("helvetica", size: 14))
                                            .foregroundColor(hostSelected ? .clear : .black)
                                    }
                                }
                            )
                            .padding()
                    }

                    Button(action: {
                        if hostSelected {
                            userSelected.toggle()
                        } else {
                            hostSelected.toggle()
                            userSelected.toggle()
                        }
                    }) {
                        Text("Employee")
                            .font(Font.custom("helvetica", size: 18))
                            .foregroundColor(userSelected ? .black : skyBlueColor.skyBlue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(userSelected ? Color.black : Color.black, lineWidth: 3)
                                    .frame(width: 125, height: 150)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 125, height: 150)
                                    .foregroundColor(userSelected ? Color.clear : skyBlueColor.skyBlue)
                            )
                            .overlay(
                                withAnimation{
                                    VStack(spacing: 5){
                                        Text("Employee")
                                            .font(Font.custom("helvetica", size: 18))
                                            .foregroundColor(userSelected ? .clear : .black)
                                        Spacer()
                                        Text("Find your")
                                            .font(Font.custom("helvetica", size: 14))
                                            .foregroundColor(userSelected ? .clear : .black)
                                        Text("Ideal")
                                            .font(Font.custom("helvetica", size: 14))
                                            .foregroundColor(userSelected ? .clear : .black)
                                        Text("Candidate")
                                            .font(Font.custom("helvetica", size: 14))
                                            .foregroundColor(userSelected ? .clear : .black)
                                    }
                                }
                            )
                            .padding()
                    }
                }
                .padding(.top,80)
                Spacer()
                if (userSelected && hostSelected){
                    Text("Continue")
                        .font(Font.custom("helvetica-bold",size: 18))
                        .foregroundColor(Color.white)
                        .frame(width:300,height:40)
                        .background(Color.black)
                        .opacity(0.4)
                        .cornerRadius(10)
                        .padding()
                }else{
                    NavigationLink{
                        if userSelected{
                            userName()
                        }
                        if hostSelected{
                            hostError()
                        }
                    }label:{
                        Text("Continue")
                            .font(Font.custom("helvetica-bold",size: 18))
                            .opacity(3)
                            .foregroundColor(Color.white)
                            .frame(width:300,height:40)
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding()
                        }
                }
                Button(action: {
                    dismiss()
                }){
                    Text("Already have an Account?")
                        .font(Font.custom("helvetica-bold",size: 18))
                        .foregroundColor(Color.black)
                    
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    signUpView()
}
