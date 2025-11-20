//
//  deleteAccount.swift
//  JobsMatch
//
//  Created by ivans Android on 9/25/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SendbirdChatSDK


struct deleteAccount: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State var open = false
    @State var selected: ImageResource? = nil
    @State var text: String
    @FocusState var FocusState
    @State var showButtons = false
    @State var showSend = false
    @State private var showingAlert = false
    
    private func sendFeedback() {
        let db = Firestore.firestore()
        let email = authService.currentUser?.email ?? "" // Get user email from AuthService
        let selectedStars = stateSelection(selected: $selected).selectedStarsCount()
    
        let feedbackData: [String: Any] = [
            "description": text,
            "email": email,
            "time": Timestamp(date: Date()), // Automatically capture the current timestamp
            "topic": "\(selectedStars)/5 stars" // Set the topic as the number of stars
        ]
        
        // Add document to the "feedbacks" collection
        db.collection("feedbacks").addDocument(data: feedbackData) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Feedback successfully saved!")
            }
        }
        
        // Clear feedback text after sending
        text = ""
        selected = nil
        withAnimation {
            open = false
            showButtons = false
        }
    }
    
    private func deleteUserAccount(authService: AuthService) {
        guard let user = Auth.auth().currentUser else { return }
        guard let userId = UserDefaults.standard.string(forKey: "user_uuid") else {
            print("DEBUG: No user UUID found")
            return
        }
        let db = Firestore.firestore()
        
        // Create a dispatch group to manage all async operations
        let group = DispatchGroup()
        
        // Step 1: Delete all jobs applications
        group.enter()
        let jobseekerRef = db.collection("jobseekers").document(userId)
        db.collection("jobs")
        .getDocuments { (jobsSnapshot, error) in
            if let error = error {
                print("Error getting jobs: \(error)")
                group.leave()
                return
            }
            
            let jobsGroup = DispatchGroup()
            
            jobsSnapshot?.documents.forEach { jobDoc in
                jobsGroup.enter()
                
                // Get the current job data
                if let jobData = jobDoc.data()["job_applicants"] as? [[String: Any]] {
                    // Filter out any applications where the applicant path matches the user's path
                    let filteredApplicants = jobData.filter { applicationMap in
                        if let applicantRef = applicationMap["applicant"] as? DocumentReference {
                            return applicantRef.path != "jobseekers/\(userId)"
                        }
                        return true
                    }
                    
                    // Update the job document with the filtered applicants
                    jobDoc.reference.updateData([
                        "job_applicants": filteredApplicants
                    ]) { error in
                        if let error = error {
                            print("Error updating job document: \(error)")
                        }
                        jobsGroup.leave()
                    }
                } else {
                    jobsGroup.leave()
                }
            }
            group.leave()
        }
        
        // Step 2: Delete all feedbacks
        group.enter()
        db.collection("feedbacks")
            .whereField("email", isEqualTo: authService.currentUser?.email ?? "")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting feedbacks: \(error)")
                    group.leave()
                    return
                }
                
                let feedbacksGroup = DispatchGroup()
                
                snapshot?.documents.forEach { doc in
                    feedbacksGroup.enter()
                    doc.reference.delete { err in
                        if let err = err {
                            print("Error deleting feedback: \(err)")
                        }
                        feedbacksGroup.leave()
                    }
                }
                
                feedbacksGroup.notify(queue: .main) {
                    group.leave()
                }
            }
        
        // Step 3: Delete main jobseeker document
            group.enter()
            db.collection("jobseekers")
                .document(userId)
                .delete { error in
                    if let error = error {
                        print("Error deleting jobseeker document: \(error)")
                    }
                    group.leave()
                }
            
            // After all Firestore deletions are complete
            group.notify(queue: .main) {
                // Step 4: Delete Sendbird user
                deleteSendbirdUser(userId: userId) { result in
                    switch result {
                    case .success:
                        print("Sendbird user deleted successfully")
                        
                        // Step 5: Delete Firebase Auth account
                        user.delete { error in
                            if let error = error {
                                print("Error deleting auth account: \(error.localizedDescription)")
                            }
                            
                            // Whether auth deletion succeeds or fails, sign out
                            do {
                                try Auth.auth().signOut()
                                // Clear UserDefaults
                                UserDefaults.standard.removeObject(forKey: "user_uuid")
                                // Disconnect Sendbird
                                SendbirdManager.shared.disconnect()
                                // Sign out of AuthService
                                AuthService.shared.signOut()
                                print("User signed out and cleaned up successfully")
                            } catch {
                                print("Error during cleanup: \(error)")
                            }
                        }
                        
                    case .failure(let error):
                        print("Failed to delete Sendbird user: \(error)")
                        // Still proceed with sign out
                        AuthService.shared.signOut()
                    }
                }
            }
    }
    
    private func deleteSendbirdUser(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let sendbirdApiToken = Bundle.main.object(forInfoDictionaryKey: "SENDBIRD_API_TOKEN") as? String ?? ""
            let sendbirdAppId = Bundle.main.object(forInfoDictionaryKey: "SENDBIRD_APP_ID") as? String ?? "" // Your Sendbird App ID

           guard let url = URL(string: "https://api-\(sendbirdAppId).sendbird.com/v3/users/\(userId)") else {
               print("Invalid Sendbird URL")
               completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "DELETE"
           request.setValue(sendbirdApiToken, forHTTPHeaderField: "Api-Token")

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Failed to delete Sendbird user: \(error.localizedDescription)")
                   completion(.failure(error))
                   return
               }

               if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                   print("Sendbird user deleted successfully")
                   completion(.success(true))
               } else {
                   print("Failed to delete Sendbird user")
                   completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete Sendbird user"])))
               }
           }.resume()
       }
    
    
    
    var rateExperience: some View{
        VStack(alignment: .leading, spacing: 8){
            Text("Rate Experience")
                .font(Font.custom("Orkney-Bold", size: 17))
            Text("How do you feel about using our app, please rate your experience")
        }
        .foregroundStyle(.white)
    }
    
    var textEditorView: some View{
        TextEditor(text: $text)
            .focused($FocusState)
            .toolbar{
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button{
                        FocusState = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
    
    var body: some View {
        ScrollView{
            VStack {
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
                .padding()
            }
            VStack{
                Text("JobsMatch")
                    .font(Font.custom("Orkney-Bold", size: 30))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            Spacer()
            VStack{
                Text("We're sad to see you leave \(authService.currentUser?.full_name ?? ""), but we truly appreciate every swipe you made with us. We’d love to hear from you to help us improve. We hope to see you back in the future!")
                    .font(Font.custom("Orkney-Regular", size: 20))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("- JobsMatch Team")
                    .font(Font.custom("Orkney-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.trailing, .bottom])
                    .padding(.bottom,200)
                    .padding(.top,-15)
            }
            Spacer()
            VStack(alignment: open ? .leading : .center, spacing: 17){
                Text("Feedback")
                    .font(Font.custom("Orkney-Bold", size: 20))
                    .foregroundStyle(.white)
                if open{
                    rateExperience
                    stateSelection(selected: $selected)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                    textEditorView
                }
            }
            .padding()
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: open ? .topLeading : .center)
            .frame(height: open ? 350 : 60, alignment: open ? .topLeading : .center)
            .background(
                RoundedRectangle(cornerRadius: open ? 20 : 10)
                    .fill(Color.black) // Replace this with your desired color
            )
            .clipped()
            .padding(.top,-230)
            .padding()
            .onTapGesture {
                open = true
                if !open{
                    showButtons = false
                }else{
                    withAnimation(.spring.delay(0.3)){
                        showButtons = true
                    }
                }
            }
            .overlay(
                Group {
                    if open {
                        SendAndCancel(send: $showSend, Cancel: {
                            selected = nil
                            text = ""
                            withAnimation {
                                open = false
                                showButtons = false
                            }
                        }, Send: {
                            // Send logic here
                            sendFeedback()
                        })
                        .padding(.bottom,50)
                        .offset(y: showButtons ? 120 : 0)
                    }
                }
            )
            .onChange(of: selected){ oldValue, newValue in
                withAnimation{
                    showSend = newValue != nil
                }
            }
            .onChange(of: text){ oldValue, newValue in
                withAnimation{
                    showSend = newValue != ""
                }
            }
            Spacer()
            Button(action: {
                print("deleted account")
                showingAlert = true
                }) {
                Text("Delete")
                    .font(Font.custom("Orkney-Bold", size: 20))
                    .opacity(3)
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 40)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .alert("Are you sure you want Delete this JobsMatch Account?", isPresented: $showingAlert){
                    Button("Yes", role: .destructive) {
                        deleteUserAccount(authService: AuthService())
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .padding(.top,100)
        }
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    deleteAccount(text: "")
        .environmentObject(AuthService())
}




