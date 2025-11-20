//
//  privacyPolicy.swift
//  JobsMatch
//
//  Created by ivans Android on 7/10/24.
//

import SwiftUI

struct privacyPolicy: View {
    @Environment(\.dismiss) var dismiss

    
    // Picker options
    private let optionsVisibility = ["Recruiters", "Disabled"]
    private let optionsDataSharing = ["All", "Select", "None"]
    private let optionsLocation = ["All the Time", "When Active"]
    private let optionsCookies = ["Enabled", "Disabled"]

    var body: some View {
        ScrollView {
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
            Text("Privacy Policy")
                .font(Font.custom("Orkney-Bold", size: 30))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            VStack(spacing: -10) {
                Text("1. Introduction")
                    .font(Font.custom("Orkney-Bold", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("JobsMatch (“we”, “our”, or “us”) is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed by JobsMatch. This Privacy Policy applies to our website and its associated subdomains (collectively, our “Service”) alongside our application, JobsMatch. By accessing or using our Service, you signify that you have read, understood, and agree to our collection, storage, use, and disclosure of your personal information as described in this Privacy Policy and our Terms of Service.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("2. Definitions and Key Terms")
                    .font(Font.custom("Orkney-Bold", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("To help explain things as clearly as possible in this Privacy Policy, every time any of these terms are referenced, they are strictly defined as:")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Company: when this policy mentions “Company,” “we,” “us,” or “our,” it refers to JobsMatch, that is responsible for your information under this Privacy Policy.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Country: where JobsMatch or the owners/founders of JobsMatch are based, in this case, is the United States.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Customer: refers to the company, organization, or person that signs up to use the JobsMatch Service to manage the relationships with your consumers or service users.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Device: any internet-connected device such as a phone, tablet, computer, or any other device that can be used to visit JobsMatch and use the services.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• IP address: Every device connected to the Internet is assigned a number known as an Internet protocol (IP) address. These numbers are usually assigned in geographic blocks. An IP address can often be used to identify the location from which a device is connecting to the Internet.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Personnel: refers to those individuals who are employed by JobsMatch or are under contract to perform a service on behalf of one of the parties.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Personal Data: any information that directly, indirectly, or in connection with other information — including a personal identification number — allows for the identification or identifiability of a natural person.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Service: refers to the service provided by JobsMatch as described in the relative terms (if available) and on this platform.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Third-party service: refers to advertisers, contest sponsors, promotional and marketing partners, and others who provide our content or whose products or services we think may interest you.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• Website: JobsMatch’s site, which can be accessed via this URL: https://jobsmatch.io/.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("• You: a person or entity that is registered with JobsMatch to use the Services.")
                    .font(Font.custom("Orkney-Regular", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
            }
            .padding()
        }
    }
}

#Preview {
    privacyPolicy()
}

