//
//  currentActiveJob.swift
//  JobsMatch
//
//  Created by ivans Android on 5/20/24.
//


 import SwiftUI
 import FirebaseFirestore
/*
 struct currentActiveJob: View {
     @Environment(\.dismiss) var dismiss
     @StateObject private var viewModel: CurrentActiveJobViewModel
     
     init(job: HostJob) {
         _viewModel = StateObject(wrappedValue: CurrentActiveJobViewModel(job: job))
     }
     
     var body: some View {
         NavigationView {
             ScrollView {
                 HStack {
                     Button(action: { dismiss() }) {
                         Image(systemName: "chevron.left")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 22, height: 22)
                             .foregroundColor(Color.black)
                             .padding()
                     }
                     Spacer()
                     /*
                      NavigationLink(destination: editCurrentJob(job: viewModel.job)) {
                      Text("Edit Listing")
                      .font(Font.custom("Orkney-Bold", size: 18))
                      .foregroundColor(skyBlueColor.skyBlue)
                      .padding()
                      }
                      }
                      */
                 }
                 Text("Candidates")
                     .font(Font.custom("Orkney-Bold", size: 30))
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .padding()
                 VStack {
                     ForEach(viewModel.appliedUsers) { user in
                         VStack(spacing: -30) {
                             NavigationLink(destination: applicantView(user: user)) {
                                 HStack {
                                     Text("\(user.first_name ?? "") \(user.last_name ?? "")")
                                         .foregroundStyle(.black)
                                         .font(Font.custom("Orkney-Bold", size: 14))
                                         .frame(maxWidth: .infinity, alignment: .leading)
                                         .padding()
                                     Text("")
                                         .foregroundStyle(.black)
                                         .font(Font.custom("Orkney-Bold", size: 14))
                                         .frame(maxWidth: .infinity, alignment: .trailing)
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
         .onAppear {
             viewModel.fetchAppliedUsers()
         }
     }
 }

 class CurrentActiveJobViewModel: ObservableObject {
     @Published var job: HostJob
     @Published var appliedUsers: [User] = []
     
     private let db = Firestore.firestore()
     
     init(job: HostJob) {
         self.job = job
     }
     
     func fetchAppliedUsers() {
         guard let usersApplied = job.users_applied else { return }
         
         for (user_id, _) in usersApplied {
             db.collection("jobseekers").document(user_id).getDocument { [weak self] (document, error) in
                 if let document = document, document.exists {
                     do {
                         var user = try document.data(as: User.self)
                         user.id = document.documentID
                         DispatchQueue.main.async {
                             self?.appliedUsers.append(user)
                         }
                     } catch {
                         print("Error decoding user: \(error)")
                     }
                 } else {
                     print("User document does not exist")
                 }
             }
         }
     }
     
     func getUserScore(for userId: String) -> Int {
         guard let application = job.users_applied?[userId] else { return 0 }
         return Int(application.percent ?? 0)
     }
 }

 // Placeholder for editCurrentJob view
 struct editCurrentJobHost: View {
     var job: HostJob
     
     var body: some View {
         Text("Edit Job: \(job.job_name ?? "")")
     }
 }

 // Placeholder for applicantView
 struct applicantView: View {
     var user: User
     
     var body: some View {
         Text("Applicant: \(user.first_name ?? "") \(user.last_name ?? "")")
     }
 }

 #Preview {
     let sampleJob = HostJob(id: "sample-id", job_name: "Sample Job")
     return currentActiveJob(job: sampleJob)
 }
*/
