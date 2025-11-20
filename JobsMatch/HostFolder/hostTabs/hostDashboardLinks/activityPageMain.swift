




import SwiftUI
import FirebaseFirestore
import SendbirdChatSDK
import SendbirdUIKit

struct activityPageMain: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSegment = 0
    @EnvironmentObject var authServiceHost: AuthServiceHost
    @StateObject private var jobManager: JobManager
    @State private var isLoading = true

    init(authService: AuthService) {
        _jobManager = StateObject(wrappedValue: JobManager(authService: authService))
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color.black)
                            .padding()
                    }
                    if isLoading {
                        ProgressView()
                    } else if selectedSegment == 0 {
                        if let host = authServiceHost.currentHost {
                            activeJobs(selectedSegment: $selectedSegment, jobManager: jobManager, host: host)
                                .environmentObject(authServiceHost)
                        } else {
                            Text("No host found")
                        }
                    } else {
                        pastJobs(selectedSegment: $selectedSegment, jobManager: jobManager)
                    }
                    Spacer(minLength: 55)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        isLoading = true
        if authServiceHost.currentHost == nil, let hostId = authServiceHost.hostSession?.uid {
            authServiceHost.fetchCurrentHost(for: hostId)
        }
        if let host = authServiceHost.currentHost {
            await jobManager.fetchHostJobs(for: host)
        }
        isLoading = false
    }
}

struct activeJobs: View {
    @Binding var selectedSegment: Int
    @ObservedObject var jobManager: JobManager
    let host: Host
    @State private var scrollOffset: CGFloat = 0
    let maxBubblePickerHeight: CGFloat = 60
    
    var body: some View {
        VStack {
            BubblePickerViewHost(selectedCategoryIndex: $selectedSegment, scrollOffset: $scrollOffset, maxHeight: maxBubblePickerHeight)
            
            ScrollView {
                GeometryReader { geometry in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                }
                .frame(height: 0)
                
                Text("Active Jobs")
                    .font(Font.custom("Orkney-Bold", size: 30))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .padding()
                
                VStack {
                    let activeJobs = jobManager.hostJobs.filter { job in
                        guard let jobId = job.id else {
                            print("Job has no ID")
                            return false
                        }
                        let isAssigned = host.jobs?.contains(where: { $0.documentID == jobId }) ?? false
                        print("Job \(jobId) is assigned: \(isAssigned)")
                        return isAssigned
                    }
                    
                    Text("Debug: Total jobs: \(jobManager.jobs.count), Active jobs: \(activeJobs.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if activeJobs.isEmpty {
                        Text("No active jobs found")
                            .font(Font.custom("Orkney-Bold", size: 18))
                            .padding()
                    } else {
                        /*
                        ForEach(activeJobs) { job in
                            VStack(spacing: -30) {
                                HStack {
                                    Text("Date Posted: \(job.dates ?? "")")
                                        .font(Font.custom("Orkney-Bold", size: 14))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Candidates: \(job.users_applied?.count ?? 0)")
                                        .font(Font.custom("Orkney-Bold", size: 14))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding()
                                NavigationLink(destination: currentActiveJob(job: job)) {
                                    cardViewHost(job: job)
                                        .padding()
                                }
                                Divider()
                                    .padding()
                            }
                        }
                        */
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.scrollOffset = value
            }
        }
    }
}

struct pastJobs: View {
    @Binding var selectedSegment: Int
    @ObservedObject var jobManager: JobManager
    @State private var scrollOffset: CGFloat = 0
    let maxBubblePickerHeight: CGFloat = 60

    var body: some View {
        VStack {
            BubblePickerViewHost(selectedCategoryIndex: $selectedSegment, scrollOffset: $scrollOffset, maxHeight: maxBubblePickerHeight)

            ScrollView {
                GeometryReader { geometry in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                }
                .frame(height: 0)

                Text("Past Jobs")
                    .font(Font.custom("Orkney-Bold", size: 30))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .padding()
                /*
                VStack {
                    ForEach(jobManager.getPastHostJobs()) { job in
                        VStack(spacing: -30) {
                            HStack {
                                Text("Date Posted: \(job.dates ?? "")")
                                    .font(Font.custom("Orkney-Bold", size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                Text("Candidates: \(job.users_applied?.count ?? 0)")
                                    .font(Font.custom("Orkney-Bold", size: 14))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding()
                            }
                            .padding(.horizontal)
                            /*
                            NavigationLink(destination: pastJobView(job: job)) {
                                cardViewHost(job: job)
                                    .padding()
                            }
                             */
                            Divider()
                                .padding()
                        }
                    }
                }
                */
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.scrollOffset = value
            }
        }
    }
}

struct BubblePickerViewHost: View {
    @Environment(\.dismiss) var dismiss
    let categories = ["Active", "History"]
    @Binding var selectedCategoryIndex: Int
    @Binding var scrollOffset: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        let scaleFactor = max(0.5, 1 - (scrollOffset / 300))

        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22 * scaleFactor, height: 22 * scaleFactor)
                    .foregroundColor(Color.black)
                    .padding()
            }
            Spacer()
            ForEach(0..<categories.count, id: \.self) { index in
                Button(action: {
                    self.selectedCategoryIndex = index
                }) {
                    Text(self.categories[index])
                        .padding(.vertical, 8 * scaleFactor)
                        .padding(.horizontal, 20 * scaleFactor)
                        .background(self.selectedCategoryIndex == index ? skyBlueColor.skyBlue : Color.clear)
                        .foregroundColor(self.selectedCategoryIndex == index ? .white : skyBlueColor.skyBlue)
                        .cornerRadius(20 * scaleFactor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20 * scaleFactor)
                                .stroke(skyBlueColor.skyBlue, lineWidth: 2 * scaleFactor)
                        )
                }
                .animation(.easeInOut, value: selectedCategoryIndex)
            }
            Spacer()
            Spacer()
        }
        .padding(.vertical, 5 * scaleFactor)
        .frame(maxHeight: maxHeight * scaleFactor)
        .navigationBarBackButtonHidden(true)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}





// Placeholder for editCurrentJob view
struct editCurrentJobHost: View {
    var job: HostJob
    
    var body: some View {
        Text("Edit Job: \(job.job_title ?? "")")
    }
}

// Placeholder for applicantView
struct applicantView: View {
    @Environment(\.presentationMode) var presentationMode
    var user: User
    var job: HostJob
    var hostId: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var viewState: ViewState = .initial
    @StateObject var channelManager: ChannelManager
    @EnvironmentObject var authServiceHost: AuthServiceHost
    
    enum ViewState {
        case initial, loading, success, error
    }
    
    var onCreateChatButtonTapped: () -> Void
    
    var body: some View {
        VStack {
            Text("Applicant: \(user.full_name ?? "")")
                .font(.title)
            
            Text("Email: \(user.email ?? "")")
                .font(.subheadline)
            
            if isLoading {
                ProgressView()
            } else {
                HStack {
                    Button(action: { handleApplicant(accept: true) }) {
                        Text("Accept")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { handleApplicant(accept: false) }) {
                        Text("Reject")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            print("applicantView appeared")
        }
    }
    
    //add ashishtechie12@gmail.com on the firebase as a collaborator
    // add test2@gmail.com on the host side
    
    func handleApplicant(accept: Bool) {
        isLoading = true
        viewState = .loading
        
        if accept {
            acceptApplicant()
        } else {
            rejectApplicant()
        }
    }
    
    func acceptApplicant() {
        return
        
        
        //onCreateChatButtonTapped()
        
        /*
        createSendbirdChat(hostId: hostId, applicantId: applicantId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let channel):
                    self.updateJobStatus(status: "accepted", channelURL: channel.channelURL)
                    self.updateUserChats(userId: applicantId, hostId: self.hostId, jobId: jobId, channelURL: channel.channelURL)
                    self.updateAllChats(userId: applicantId, hostId: self.hostId, jobId: jobId, channelURL: channel.channelURL)
                                        channelManager.addChannel(channel)
                    channelManager.addChannel(channel)
                case .failure(let error):
                    handleError("Failed to create chat: \(error.localizedDescription)")
                }
            }
        }
        */
    }
    
    
    func updateAllChats(userId: String, hostId: String, jobId: String, channelURL: String) {
        let db = Firestore.firestore()
        
        // Update jobseeker's all_chats
        let jobseekerRef = db.collection("jobseekers").document(userId)
        jobseekerRef.updateData([
            "all_chats.\(jobId)": channelURL
        ]) { error in
            if let error = error {
                print("Error updating jobseeker's all_chats: \(error.localizedDescription)")
            }
        }
        
        // Update host's all_chats (assuming hosts/recruiters also have an all_chats field)
        let hostRef = db.collection("recruiters").document(hostId)
        hostRef.updateData([
            "all_chats.\(jobId)": channelURL
        ]) { error in
            if let error = error {
                print("Error updating host's all_chats: \(error.localizedDescription)")
            }
        }
    }
    

    func updateUserChats(userId: String, hostId: String, jobId: String, channelURL: String) {
        let db = Firestore.firestore()
        
        // Update jobseeker's all_chats
        db.collection("jobseekers").document(userId).updateData([
            "all_chats.\(jobId)": channelURL
        ]) { error in
            if let error = error {
                print("Error updating jobseeker chats: \(error.localizedDescription)")
            }
        }
        
        // Update host's all_chats
        db.collection("recruiters").document(hostId).updateData([
            "all_chats.\(jobId)": channelURL
        ]) { error in
            if let error = error {
                print("Error updating host chats: \(error.localizedDescription)")
            }
        }
    }

    func createSendbirdChat(hostId: String, applicantId: String, completion: @escaping (Result<GroupChannel, Error>) -> Void) {
        let params = GroupChannelCreateParams()
        params.userIds = [hostId, applicantId]
        params.isDistinct = true

        GroupChannel.createChannel(params: params) { (groupChannel, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let groupChannel = groupChannel else {
                let error = NSError(domain: "com.yourdomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create group channel"])
                completion(.failure(error))
                return
            }

            completion(.success(groupChannel))
        }
    }
    
    func rejectApplicant() {
        updateJobStatus(status: "rejected")
    }
    
    func updateJobStatus(status: String, channelURL: String? = nil) {
        guard let job_id = job.id, let user_id = user.id else {
            handleError("Missing job or user ID")
            return
        }
        
        let db = Firestore.firestore()
        let jobRef = db.collection("jobs").document(job_id)
        
        
        var updateData: [String: Any] = [:]
        if status == "accepted" {
            updateData["assignedTo_id"] = user_id
            if let channelURL = channelURL {
                updateData["channelURL"] = channelURL
            }
        }
        
        jobRef.updateData(updateData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    handleError("Failed to update job status: \(error.localizedDescription)")
                } else {
                    handleSuccess(status == "accepted" ? "Applicant accepted and chat created" : "Applicant rejected")
                    if status == "rejected" {
                        jobRef.updateData([
                            "users_applied.\(user_id)": FieldValue.delete()
                        ])
                    }
                }
            }
        }
    }
    
    func handleError(_ message: String) {
        alertMessage = message
        showingAlert = true
        isLoading = false
        viewState = .error
    }
    
    func handleSuccess(_ message: String) {
        alertMessage = message
        showingAlert = true
        isLoading = false
        viewState = .success
    }
}

//#Preview {
//    activityPageMain()



