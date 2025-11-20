//
//  helpSupport.swift
//  JobsMatch
//
//  Created by ivans Android on 1/9/25.
//

import SwiftUI
import FirebaseFirestore

struct helpSupport: View {
    @EnvironmentObject var authService: AuthService
    @State var selected: ImageResource? = nil
    @Environment(\.dismiss) var dismiss
    @State var text = ""
    @FocusState var FocusState
    @State var open: Bool = false
    @State var showButtons = false
    @State var showSend = false
    @State var topic = ""
    
    private func sendSupportTicket() {
        let db = Firestore.firestore()
        let email = authService.currentUser?.email ?? "" // Get user email from AuthService
    
        let ticketData: [String: Any] = [
            "description": text,
            "email": email,
            "time": Timestamp(date: Date()), // Automatically capture the current timestamp
            "topic": topic // Set the topic as the number of stars
        ]
        
        // Add document to the "feedbacks" collection
        db.collection("feedbacks").addDocument(data: ticketData) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Feedback successfully saved!")
            }
        }
        
        // Clear feedback text after sending
        text = ""
        topic = ""
        withAnimation {
            open = false
            showButtons = false
        }
    }
    
    
    var rateExperience: some View{
        VStack(alignment: .leading, spacing: 8){
            Text("Support Ticket")
                .font(Font.custom("Orkney-Bold", size: 17))
            Text("Please fill out a support ticket with a title and description")
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
            .onTapGesture {
                UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
            }
    }
    var topicEditorView: some View{
        TextField("",text: $topic)
            .focused($FocusState)
            .disableAutocorrection(true)
            .font(Font.custom("Orkney-Regular", size: 12))
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(6.0)
            .padding(.horizontal,0)
            .onTapGesture {
                UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
            }
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
                Text("We apolgize beforehand")
                    .font(Font.custom("Orkney-Regular", size: 20))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                Text("Fill out a support ticket so we can fix your issue")
                    .font(Font.custom("Orkney-Regular", size: 20))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack(alignment: open ? .leading : .center, spacing: 17){
                Text("Help & Support")
                    .font(Font.custom("Orkney-Bold", size: 20))
                    .foregroundStyle(.white)
                    .onTapGesture {
                        withAnimation{
                            open.toggle()
                        }
                        if !open{
                            showButtons = false
                        }else{
                            withAnimation(.spring.delay(0.3)){
                                showButtons = true
                            }
                        }
                    }
                if open{
                    rateExperience
                    topicEditorView
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
            .padding(.top,10)
            .padding()
            .overlay(
                Group {
                    if open {
                        SendAndCancel(send: $showSend, Cancel: {
                            topic = ""
                            text = ""
                            withAnimation {
                                open = false
                                showButtons = false
                            }
                        }, Send: {
                            // Send logic here
                            sendSupportTicket()
                        })
                        .padding(.top,190)
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
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    helpSupport()
        .environmentObject(AuthService())
}



