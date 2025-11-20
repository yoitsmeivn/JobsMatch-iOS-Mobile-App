//
//  applicantView.swift
//  JobsMatch
//
//  Created by ivans Android on 5/20/24.
//

/*
import SwiftUI

struct applicantView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = chatsviewmodel()
    @State private var query = ""
    var user: User
    @State private var navigateToNewChat = false
    @State private var newChat: Chat?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
            Text("\(user.firstName) \(user.lastName)")
                .font(Font.custom("Orkney-Bold", size: 30))
                .padding(.top, 20)

            Text("Email: \(user.email)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Age: \(user.age)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Work Eligibility: \(user.workEligiblity)")
                .font(Font.custom("Orkney-Regular", size: 18))

            //Text("Job Filters: \(user.jobFilters.joined(separator: ", "))")
              //  .font(Font.custom("Orkney-Regular", size: 18))

            Text("Highest Education: \(user.highestEducation)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Desired Position: \(user.desiredPosition)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Resume: \(user.resume)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Gender: \(user.gender)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Sexual Orientation: \(user.sexualOrientation)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Pronouns: \(user.pronouns)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Bio: \(user.userBio)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Text("Score: \(user.score)")
                .font(Font.custom("Orkney-Regular", size: 18))

            Spacer()
            Button(action: {
                newChat = viewModel.createNewChat(with: user)
                navigateToNewChat = true
            }) {
                Text("New Chat")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Applicant Details")
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToNewChat) {
            chatView(chat: newChat ?? Chat(person: Person(name: "Default", imgstring: ""), messages: []))
                .environmentObject(viewModel)
        }
        .padding()
    }
}

struct applicantView_Previews: PreviewProvider {
    static var previews: some View {
        if let user = mockUsers.first(where: { $0.id == UUID(uuidString: "your-uuid-string-here") }) {
            applicantView(user: user)
        } else {
            Text("User not found")
        }
    }
}

*/
