//
//  hostName.swift
//  JobsMatch
//
//  Created by ivans Android on 3/27/24.
//

import SwiftUI

struct hostName: View {
    @State var companyEmail = ""
    @State var companyName = ""
    @State var companyAdminName = ""
    @State var adminPosition = ""
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
                Text("Let's continue with legal business name, email, and company administrator")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                VStack(spacing: 12){
                    TextField("Enter your Company",text: $companyName)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                    
                    
                    TextField("Enter your Main Email",text: $companyEmail)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                    
                    TextField("Administrator Name & Last Name",text: $companyAdminName)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                    
                    TextField("Administrator Position",text: $adminPosition)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                    
                }
                .padding()
                Spacer()
                NavigationLink{
                   hostAddress(hostAddress: hostAddressClass())
                }label:{
                    Text("Continue")
                        .font(Font.custom("Orkney-Bold",size: 18))
                        .opacity(3)
                        .foregroundColor(skyBlueColor.skyBlue)
                        .frame(width:300,height:40)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                NavigationLink{
                    recruitName()
                }label:{
                    Text("Are you a Recruiter?")
                        .font(Font.custom("Orkney-Bold",size: 18))
                        .opacity(3)
                        .foregroundColor(.black)
                        .padding()
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    hostName()
}
