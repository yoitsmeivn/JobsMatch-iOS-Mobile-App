//
//  hostError.swift
//  JobsMatch
//
//  Created by ivans Android on 6/20/24.
//

import SwiftUI

struct hostError: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack{
            skyBlueColor.skyBlue
                .ignoresSafeArea()
            VStack(spacing: 10){
                HStack{
                    Image("JobsMatchBluebackground")
                        .resizable()
                        .frame(width:200,height:55)
                        .padding(.bottom)
                    Spacer()
                }
                .padding()
                Spacer()
                Text("Oops, page is still in construction.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .center)
                Image(systemName: "hammer")
                    .resizable()
                    .frame(width:100,height:100)
                Text("Please return and create a User Profile      Host Profile is coming!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Button(action: {
                    dismiss()
                }){
                    Text("Home")
                        .font(Font.custom("Orkney-Bold",size: 18))
                        .opacity(3)
                        .foregroundColor(skyBlueColor.skyBlue)
                        .frame(width:300,height:40)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    hostError()
}
