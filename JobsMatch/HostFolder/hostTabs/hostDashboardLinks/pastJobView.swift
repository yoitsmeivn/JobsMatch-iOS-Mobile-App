//
//  pastJobView.swift
//  JobsMatch
//
//  Created by ivans Android on 5/22/24.
//
/*
import SwiftUI

struct pastJobView: View {
    @Environment(\.dismiss) var dismiss
    var job: hostJob
    
    var usersFound: [User] {
            mockUsers.filter { job.usersFound.contains($0.id) }
        }
    
    var body: some View {
        NavigationView{
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
                Text("Candidates")
                    .font(Font.custom("Orkney-Bold", size: 30))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                VStack {
                    ForEach(usersFound) { user in
                        VStack(spacing: -30) {
                            NavigationLink(destination: applicantView(user:user)) {
                                HStack {
                                    Text("\(user.firstName) \(user.lastName)")
                                        .foregroundStyle(.black)
                                        .font(Font.custom("Orkney-Bold", size: 14))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                    Image(systemName:"checkmark")
                                        .resizable()
                                        .foregroundStyle(skyBlueColor.skyBlue)
                                        .frame(width:16,height:16)
                                        .padding()
                                }
                            }
                            .padding(.horizontal)
                            Divider()
                                .padding()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    if let job = mockHostPastJobs.first(where: { $0.id == UUID(uuidString: "your-uuid-string-here") }) {
        pastJobView(job: job)
    } else {
        Text("User not found")
    }
}
*/
