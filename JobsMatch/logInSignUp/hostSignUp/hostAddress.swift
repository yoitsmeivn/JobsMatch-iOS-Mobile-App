//
//  hostAddress.swift
//  JobsMatch
//
//  Created by ivans Android on 4/18/24.
//

import SwiftUI

struct hostAddress: View {
    @ObservedObject var hostAddress: hostAddressClass

    var body: some View {
        ZStack {
            skyBlueColor.skyBlue
                .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack{
                    Image("JobsMatchBluebackground")
                        .resizable()
                        .frame(width:200,height:55)
                        .padding(.bottom)
                    Spacer()
                }
                .padding()
                Spacer()
                Text("Let's get company details")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                VStack(spacing:12){
                    HStack(alignment:.center,spacing:-23){
                        Image(systemName:"house")
                        TextField("Street Address",text: $hostAddress.streetAddress)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    
                    HStack(alignment:.center,spacing:-25){
                        Image(systemName:"tree")
                        TextField("City",text: $hostAddress.city)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    
                    HStack(alignment:.center,spacing:-20){
                        Image(systemName:"globe.americas")
                        TextField("State",text: $hostAddress.state)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    
                    HStack(alignment:.center,spacing:-20){
                        Image(systemName:"mappin.and.ellipse")
                        TextField("Zip Code",text: $hostAddress.zip)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                }
                .padding()
                Spacer()

                NavigationLink {
                    companyInfo()
                } label: {
                    Text("Continue")
                        .font(Font.custom("Orkney-Bold", size: 18))
                        .opacity(3)
                        .foregroundColor(skyBlueColor.skyBlue)
                        .frame(width: 300, height: 40)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct hostAddress_Previews: PreviewProvider {
    static var previews: some View {
        hostAddress(hostAddress: hostAddressClass())
    }
}
