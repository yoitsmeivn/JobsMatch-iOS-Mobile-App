//
//  recruitName.swift
//  JobsMatch
//
//  Created by ivans Android on 6/7/24.
//



import SwiftUI

struct recruitName: View {
    @State var companyName = ""
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
                Text("Enter your Company ID")
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
                    
                    
    
                    
                }
                Button(action: {
                    dismiss()
                }){
                    Text("Company Doesn't Exist?")
                        .font(Font.custom("Orkney-Bold",size: 15))
                        .foregroundColor(Color.black)
                    
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
                        .padding()
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    recruitName()
}
