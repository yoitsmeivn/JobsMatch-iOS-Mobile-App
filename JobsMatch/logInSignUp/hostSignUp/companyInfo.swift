//
//  companyInfo.swift
//  JobsMatch
//
//  Created by ivans Android on 4/18/24.
//

import SwiftUI

struct companyInfo: View {
    @State var companyRegistration = ""
    @State var taxId = ""
    @State var companyUrl = ""
    
    @State var showBusinessOptions: Bool = false
    @State var selectedBusiness: String?

    let businessOptions = ["Software", "Engineering", "Marketing", "Business", "Biology", "Food Service","Other"]
    
    @State var showCompanySizeOptions: Bool = false
    @State var selectedCompanySize: String?
    
    let companySize = ["1-10","10-100","100-500","500-1000","1000-5000","5000+"]

    @State var showCompanyEligibility: Bool = false
    @State var selectedCompanyEligibility: String?

    let companyEligibilityOptions = ["Yes", "Yes, but I require a permit","No"]
    
    var body: some View {
        ZStack {
            // Assuming a light theme for the app; adjust colors accordingly
            skyBlueColor.skyBlue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerView
                
                instructionView
                ScrollView{
                    Text("Company Type")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    if showBusinessOptions {
                        businessSelectionView
                    } else {
                        businessButton
                    }
                    
                    Text("Company Size")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showCompanySizeOptions {
                        companySizeSelectionView
                    } else {
                        companySizeButton
                    }
                    
                    
                    Text("Company Eligibility(U.S. Specific)")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showCompanyEligibility {
                        companyEligibilitySelectionView
                    } else {
                        eligibilityButton
                    }
                    //input questions
                    Text("Legal Business Registration Number")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    TextField("Enter your Business Registration Number",text: $companyRegistration)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                    
                    Text("Tax Id")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    TextField("Enter your Business Tax ID",text: $taxId)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                    
                    Text("Company Website")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    TextField("Enter your business website",text: $companyUrl)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                
                }
                Spacer()
                NavigationLink{
                   completionHostSignUp()
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
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
        HStack{
            Image("JobsMatchBluebackground")
                .resizable()
                .frame(width:200,height:55)
                .padding(.bottom)
            Spacer()
        }
    }
    
    private var instructionView: some View {
        VStack(spacing: 20) {
            Text("Tell us about company")
                .foregroundStyle(.black)
                .font(Font.custom("Orkney-Bold", size: 18))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var businessButton: some View {
        Button(action: {
            showBusinessOptions.toggle()
        }) {
            Text(selectedBusiness ?? "Select your Company Type")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var businessSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(businessOptions, id: \.self) { business in
                MultipleSelectionRowBusiness(business: business, isSelected: business == selectedBusiness) {
                    selectedBusiness = business
                    showBusinessOptions = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: showBusinessOptions)
    }
    
    private var companySizeButton: some View {
        Button(action: {
            showCompanySizeOptions.toggle()
        }) {
            Text(selectedCompanySize ?? "Select your Company size")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var companySizeSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(companySize, id: \.self) { size in
                MultipleSelectionRowCompanySize(size: size, isSelected: size == selectedCompanySize) {
                    selectedCompanySize = size
                    showCompanySizeOptions = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: showCompanySizeOptions)
    }
    
    private var eligibilityButton: some View {
        Button(action: {
            showCompanyEligibility.toggle()
        }) {
            Text(selectedCompanyEligibility ?? "Select your status")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var companyEligibilitySelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(companyEligibilityOptions, id: \.self) { eligibility in
                MultipleSelectionRowCompanyEligibility(eligibilty: eligibility, isSelected: eligibility == selectedCompanyEligibility) {
                    selectedCompanyEligibility = eligibility
                    showCompanyEligibility = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: showCompanySizeOptions)
    }
    
    
}

struct MultipleSelectionRowBusiness: View {
    var business: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(business)
                .foregroundColor(Color.primary)
                .font(Font.custom("Orkney-Regular", size: 15))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
struct MultipleSelectionRowCompanySize: View {
    var size: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(size)
                .foregroundColor(Color.primary)
                .font(Font.custom("Orkney-Regular", size: 15))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MultipleSelectionRowCompanyEligibility: View {
    var eligibilty: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(eligibilty)
                .foregroundColor(Color.primary)
                .font(Font.custom("Orkney-Regular", size: 15))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


struct companyInfo_Previews: PreviewProvider {
    static var previews: some View {
        companyInfo()
    }
}
