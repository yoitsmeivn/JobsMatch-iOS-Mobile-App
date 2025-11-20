//
//  userAddress.swift
//  JobsMatch
//
//  Created by ivans Android on 3/28/24.
//

import SwiftUI

struct userAddress: View {
    @State var streetAddress = ""
    @State var city = ""
    @State var state = ""
    @State var zip = ""
    @State private var navigateToNextView = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            skyBlueColor.skyBlue
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
                }

            VStack(spacing: -15) {
                HStack{
                    Image("JobsMatchBluebackground")
                        .resizable()
                        .frame(width:200,height:55)
                        .padding(.bottom)
                    Spacer()
                }
                .padding()
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName:"chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color.black)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                Text("Where can we reach you?")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                VStack(spacing:12){
                    HStack(alignment:.center,spacing:-24){
                        Image(systemName:"house")
                        TextField("Street Address",text: $streetAddress)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    
                    HStack(alignment:.center,spacing:-25){
                        Image(systemName:"tree")
                        TextField("City",text: $city)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    
                    HStack(alignment:.center,spacing:-20){
                        Image(systemName:"globe.americas")
                        TextField("State/Country",text: $state)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    
                    HStack(alignment:.center,spacing:-20){
                        Image(systemName:"mappin.and.ellipse")
                        TextField("Zip Code",text: $zip)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                }
                .padding()
                Spacer()

                Button(action: {
                    saveUserData2()
                    navigateToNextView = true
                }) {
                    Text("Continue")
                        .font(Font.custom("Orkney-Bold", size: 18))
                        .opacity(3)
                        .foregroundColor(skyBlueColor.skyBlue)
                        .frame(width: 300, height: 40)
                        .background(Color.black.opacity(1.0))
                        .cornerRadius(10)
                        .padding()
                }
                .navigationDestination(isPresented: $navigateToNextView) {
                    userResume()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    
    func saveUserData2() {
        let address = "\(streetAddress), \(city), \(state), \(zip)"
        UserDefaults.standard.set(address, forKey: "address")
    }
}

struct userAddress_Previews: PreviewProvider {
    static var previews: some View {
        userAddress()
    }
}
