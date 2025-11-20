import SwiftUI
import FirebaseFirestore
import FirebaseStorage



//NOT USING 
struct JobStackView: View {
    @State private var xOffset: CGFloat = 0
    @State private var degrees: Double = 0
    @State private var currentJob: HostJob? = nil
    @State private var showAdditionalInfo = false
    @State private var selectedJob: HostJob? = nil
    @State private var isLoading: Bool = true
    
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var jobManager: JobManager
    @State private var isSheetActive: Bool = false
    
    @State private var showNotification = false
    @State private var showRedNotification = false
    @State private var notificationMessage = ""
    
    @State private var isRefreshing = false
    
    @StateObject private var imageLoader = FirebaseImageLoader()
    
    var body: some View {
        ZStack {
            if isLoading {
                Spacer()
                loadingView()
                    .frame(width: 250)
            } else if currentJob == nil {
                Spacer()
                noMoreJobsView()
            } else {
                jobCardStack()
                    .padding(.bottom, 100)
                    .padding(.top,-35)
            }
            VStack{
                Spacer()
                //notif for accepting a job
                if showNotification {
                    VStack {
                        Spacer()
                        NotificationView(message: notificationMessage)
                            .transition(.move(edge: .top))
                    }
                    .zIndex(1)
                }
                //notif for declining a job
                if showRedNotification{
                    VStack{
                        Spacer()
                        NotificationViewReject(message: notificationMessage)
                            .transition(.move(edge: .top))
                    }
                    .zIndex(1)
                }
            }
            .padding(.bottom,100)
            
            if isRefreshing {
                VStack {
                    CustomLoadingView(color: skyBlueColor.skyBlue)
                        .frame(width: 25, height: 25)
                    jobCardStack()
                        .padding(.bottom, 100)
                        .padding(.top,-35)
                }
            }
        }
        .onAppear {
            Task {
                await jobManager.loadJobsForCurrentUser() // Call the async function within a Task
                loadInitialJob()
            }
            
        }
        .sheet(isPresented: $showAdditionalInfo, onDismiss: {
            isSheetActive = false // Set to false when the sheet is dismissed
        }) {
            if let job = selectedJob {
                jobDetailsView(for: job)
                    .onAppear {
                        isSheetActive = true // Set to true when the sheet appears
                    }
                    .presentationDetents([.fraction(0.6), .fraction(0.7), .large]) // Allows the sheet to be resizable between 30%, 50%, and full height
                    .presentationDragIndicator(.visible)
            }
        }
        .refreshable {
            if !isSheetActive {
                isRefreshing = true
                await refreshJobs()
                isRefreshing = false
               }
        }
    }
    
    // Job Card Stack View (Merged from cardStackView)
    private func jobCardStack() -> some View {
        VStack{
            ScrollView {
                VStack {
                    if let job = currentJob {
                        jobCard(for: job)
                            .onTapGesture {
                                selectedJob = job
                                showAdditionalInfo.toggle()
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
            HStack {
                ZStack{
                    Circle()
                        .fill(.white)
                        .shadow(radius: 5)
                        .frame(width: 60, height: 60)
                    Button(action: {
                        Task {
                            await handleRejectJob()
                        }
                    }) {
                        Image(systemName:"pencil.slash")
                            .resizable()
                            .frame(width:35,height:35)
                            .foregroundStyle(.red)
                            .rotationEffect(.degrees(-15))
                    }
                }
                .padding(.horizontal)
                ZStack{
                    Circle()
                    .fill(.white)
                    .shadow(radius: 5)
                    .frame(width: 60, height: 60)
                    Button(action: {
                        Task {
                            await handleApplyJob()
                        }
                    }) {
                        Image(systemName:"pencil.and.list.clipboard")
                            .resizable()
                            .frame(width:35,height:35)
                            .foregroundStyle(skyBlueColor.skyBlue)
                            .rotationEffect(.degrees(15))
                            .padding(.leading,8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, -10)
        }
        .scrollIndicators(.hidden)
    }
    
    // Handle Apply Job Button Action
    private func handleApplyJob() async {
        withAnimation(.easeInOut(duration: 0.5)) {
            xOffset = screenCutOff  // Changed to positive to swipe right
            degrees = Double(screenCutOff / 25)  // Changed to positive for right rotation
        }
        
        // Add delay before executing swipe logic
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        await updateForJobResponse(didApply: true) // Apply job logic
    }

    // Handle Reject Job Button Action
    private func handleRejectJob() async {
        withAnimation(.easeInOut(duration: 0.5)) {
            xOffset = -screenCutOff  // Changed to negative to swipe left
            degrees = Double(-screenCutOff / 25)  // Changed to negative for left rotation
        }
        
        // Add delay before executing swipe logic
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        await updateForJobResponse(didApply: false) // Reject job logic
    }
    
    // Loading View
    private func loadingView() -> some View {
        VStack {
            Spacer()
            CustomLoadingView(color: .black)
                .frame(width: 25, height: 25)
        }
    }
    
    // No More Jobs View
    private func noMoreJobsView() -> some View {
        VStack {
            Spacer()
            Image("nomoreblue")
                .resizable()
                .frame(width: 300, height: 200)
                .padding()
            Text("Applied Everywhere?")
                .font(Font.custom("helvetica", size: 20))
                .foregroundColor(.black)
                .padding(.top)
            Text("Come back another time")
                .font(Font.custom("helvetica", size: 20))
                .foregroundColor(.black)
            
        }
    }
    //timestamp format from firebase
    private func formatTimestamp(_ timestamp: Timestamp?) -> String {
        guard let timestamp = timestamp else { return "" }
        
        let date = timestamp.dateValue() // Convert Timestamp to Date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.timeZone = TimeZone.current
        
        return formatter.string(from: date)
    }
    // Job Card View (Merged functionality from cardView)
    private func jobCard(for job: HostJob) -> some View {
        ZStack {
            VStack {
                HStack {
                    Text(formatTimestamp(job.date_posted))
                        .font(.custom("helvetica", size: 20))
                        .fontWeight(.heavy)
                    Spacer()
                    Text(job.job_req_id ?? "R")
                        .font(.custom("helvetica", size: 20))
                        .fontWeight(.heavy)
                }
                .padding()
                
                Spacer()
                ZStack {
                    if let companyRef = job.company_id {
                        let companyId = companyRef.documentID // Extract the string representation of the document ID
                        CompanyLogoView(companyId: companyId, imageLoader: imageLoader)
                            .frame(width: 200, height: 200)
                            .padding(.bottom,120)
                    } /*else {
                        Image("JobsMatchLogo")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .scaledToFill()
                    }*/
                    swipeIndicatorView(xOffset: $xOffset, screenCutOff: screenCutOff)
                }
                .padding(.top, 100)
                Spacer()
                VStack(spacing:-20){
                    HStack {
                        Text(job.job_title ?? "")
                            .font(.custom("helvetica", size: 18))
                            .fontWeight(.heavy)
                        Spacer()
                        Text(job.company_name ?? "")
                            .font(.custom("helvetica", size: 18))
                            .fontWeight(.heavy)
                    }
                    .padding()
                    HStack {
                        Text(job.employment_type ?? "")
                            .font(.custom("helvetica", size: 18))
                        Spacer()
                        Text(job.job_location ?? "")
                            .font(.custom("helvetica", size: 18))
                    }
                    .padding()
                }
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(.white).shadow(radius: 5))
            .padding()
        }
        .frame(width: cardWidth, height: cardHeight)
        .offset(x: xOffset)
        .rotationEffect(.degrees(degrees))
        .gesture(
            DragGesture()
                .onChanged { value in
                    xOffset = value.translation.width
                    degrees = Double(value.translation.width / 25)
                }
                .onEnded { value in
                    Task {
                        await onDragEnded(value)
                    }
                }
        )
    }
    
    // Job Details View for Sheet
    private func jobDetailsView(for job: HostJob) -> some View {
        ScrollView {
            VStack(spacing: -50) {
                VStack(spacing: -25) {
                    Text(job.job_title ?? "")
                        .font(Font.custom("helvetica-bold", size: 25))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding()
                    Text(job.company_name ?? "")
                        .font(Font.custom("helvetica-bold", size: 20))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    Text(job.job_location ?? "")
                        .font(Font.custom("helvetica", size: 15))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                .padding()
                VStack {
                    // user info divider
                    dividerWithLabel(label: "Job Description")
                        .padding()
                }
                .padding(.top, 30)
            }
            VStack {
                VStack(spacing: -5) {
                    Text("About the Position")
                        .foregroundStyle(.black)
                        .font(Font.custom("helvetica-bold", size: 15))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    Text(job.about_the_job ?? "")
                        .font(Font.custom("helvetica", size: 12))
                        .lineLimit(100, reservesSpace: false)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal, 35)
                }
                VStack(spacing: -15) {
                    VStack(spacing: -25) {
                        Text("Position")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica-bold", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        Text(job.employment_type ?? "")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    VStack(spacing: -25) {
                        Text("Location")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica-bold", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        Text(job.job_location ?? "")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    VStack(spacing: -25) {
                        Text("Salary")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica-bold", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        Text("\(job.job_pay)")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    VStack(spacing: -25) {
                        Text("Benefits")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica-bold", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    VStack(spacing: -25) {
                        Text("Requirements")
                            .foregroundStyle(.black)
                            .font(Font.custom("helvetica-bold", size: 15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                    }
                }
                VStack {
                    // user info divider
                    dividerWithLabel(label: "Company Description")
                        .padding()
                }
                VStack {
                    Text(job.about_the_job ?? "")
                        .font(Font.custom("helvetica", size: 12))
                        .lineLimit(100, reservesSpace: false)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal, 35)
                }
            }
        }
    }
    
    // Load initial job when the view appears
    private func loadInitialJob() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            loadNextJob()
            isLoading = false
        }
    }
    
    // Load next job
    private func loadNextJob() {
        if let user = authService.currentUser {
            currentJob = jobManager.getNextJob(for: user)
            selectedJob = currentJob
            resetCardPosition()
        }
    }
    
    // Handle drag ended event for swipe actions
    private func onDragEnded(_ value: DragGesture.Value) async {
        let width = value.translation.width
        
        if abs(width) <= abs(screenCutOff) {
            returnToCenter()
            return
        }
        
        let didApply = width > screenCutOff
        await updateForJobResponse(didApply:  didApply)
    }
    
    // Reset the card position to center
    private func returnToCenter() {
        xOffset = 0
        degrees = 0
    }
    
    private func updateForJobResponse(didApply: Bool) async {
        guard var user = authService.currentUser, let job = currentJob, let jobID = job.id, let userId = user.id else { return }
        
        do {
            if user.jobs_applied == nil { user.jobs_applied = [] }
            if user.jobs_declined == nil { user.jobs_declined = [] }
            
            let jobRef =  FirestoreService.collectionRef(for: .jobs).document(jobID)
            if didApply {
                user.jobs_applied?.append(jobRef)
                var modifiedJob = job
                if modifiedJob.job_applicants == nil {
                    modifiedJob.job_applicants = []
                }
                let userRef = FirestoreService.collectionRef(for: .jobSeekers).document(user.id ?? "")
                let matchPercentage = try await calculateMatchPercentage(jobId: jobID, userId: userId)
                let application = UserApplication(
                    round: 1,
                    applicant: userRef,
                    status: "incomplete",
                    comments: [],
                    date_applied: Timestamp(date: Date()),
                    percentage_match: matchPercentage
                )
                
                modifiedJob.job_applicants?.append(application)
                let jobDocRef = FirestoreService.collectionRef(for: .jobs).document(jobID)
                do {
                    try jobDocRef.setData(from: modifiedJob)
                } catch {
                    print("UPDATE JOB COMPLETED")
                    print(error)
                }
            } else {
                user.jobs_declined?.append(jobRef)
            }
            
            
            let actionString = didApply ? "applied to" : "declined"
            
            
            try await authService.updateUser(user)
            print("Successfully \(actionString) job: \(job.job_req_id ?? "nil id")")
            
            notificationMessage = "Successfully \(actionString) \(job.job_req_id ?? "")"
            
            withAnimation {
                if actionString == "applied to"{
                    showNotification = true
                }else{
                    showRedNotification = true
                }
            }
            
            // Hide notification after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showNotification = false
                    showRedNotification = false
                }
            }
            
            loadNextJob()
        } catch {
            print("Error \(didApply ? "applying for" : "declining") job: \(error.localizedDescription)")
        }
    }
    
    //calculate match percentage with model
    func calculateMatchPercentage(jobId: String, userId: String, file: String = #file, line: Int = #line) async throws -> Double {
        // Validate parameters first
        guard !userId.isEmpty else {
            print("❌ [\(line)] Error: userId is empty")
            throw NSError(domain: "ValidationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID cannot be empty"])
        }
        print("✅ [\(line)] User ID value: \(userId)")
        
        guard !jobId.isEmpty else {
            print("❌ [\(line)] Error: jobId is empty")
            throw NSError(domain: "ValidationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Job ID cannot be empty"])
        }
        print("✅ [\(line)] Job ID value: \(jobId)")
        
        // JWT Token handling
        guard let jwtToken = JWTManager.shared.getToken() else {
            return try await withCheckedThrowingContinuation { continuation in
                JWTManager.shared.generateJWTToken(userId: userId, email: authService.currentUser?.email ?? "") { result in
                    switch result {
                    case .success(let newToken):
                        JWTManager.shared.saveToken(newToken)
                        Task {
                            do {
                                let result = try await calculateMatchPercentage(jobId: jobId, userId: userId)
                                continuation.resume(returning: result)
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        
        guard let apiURL = URL(string: "https://jobsmatch.io/api/jobs/calculateSimilarity") else {
            throw NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])
        }
        
        // Create JSON body
        let requestBody: [String: Any] = [
            "userId": userId,
            "jobId": jobId
        ]
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("📦 [\(line)] Request Parameters:", requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
            }
            
            print("📥 [\(line)] Response Status Code: \(httpResponse.statusCode)")
            
            // For debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 [\(line)] Raw Response: \(responseString)")
            }
            
            // Handle response based on status code
            switch httpResponse.statusCode {
            case 200...299:
                // Define the actual response structure
                struct MatchResponse: Codable {
                    let jobId: String
                    let userId: String
                    let matchPercentage: Double
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(MatchResponse.self, from: data)
                    print("✅ [\(line)] Successfully decoded match percentage: \(decodedResponse.matchPercentage)")
                    return decodedResponse.matchPercentage
                } catch {
                    print("❌ [\(line)] Decoding failed: \(error.localizedDescription)")
                    
                    // Try to decode error response
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorResponse["error"] {
                        throw NSError(domain: "APIError", code: httpResponse.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    }
                    throw error
                }
                
            case 400:
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    throw NSError(domain: "ValidationError", code: 400,
                                userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                throw NSError(domain: "ValidationError", code: 400,
                             userInfo: [NSLocalizedDescriptionKey: "Bad Request"])
                
            case 401:
                throw NSError(domain: "AuthError", code: 401,
                             userInfo: [NSLocalizedDescriptionKey: "Unauthorized - Check your authentication credentials"])
                
            default:
                throw NSError(domain: "NetworkError", code: httpResponse.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: "Unexpected status code: \(httpResponse.statusCode)"])
            }
        } catch {
            print("❌ [\(line)] Network or processing error: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
    
    
    // Refresh jobs when user pulls to refresh
    private func refreshJobs() async {
        isLoading = true
        if let user = authService.currentUser {
            jobManager.fetchJobs(for: user)
            loadNextJob()
        }
        isLoading = false
    }
    
    // Reset card position
    private func resetCardPosition() {
        xOffset = 0
        degrees = 0
    }
    
    // Variables for layout and swipe detection
    private var screenCutOff: CGFloat {
        (UIScreen.main.bounds.width / 2) * 0.8
    }
    
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 10
    }
    
    private var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 1.45
    }
}

struct NotificationView: View {
    let message: String
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkStrokeEnd: CGFloat = 0
    
    var body: some View {
        HStack {
            Text(message)
                .font(Font.custom("helvetica", size: 15))
                .foregroundColor(Color.skyBlue)
            
            Spacer()
            
            AnimatedCheckmark()
                .frame(width: 20, height: 20)
                .scaleEffect(checkmarkScale)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding(.horizontal)
        .onAppear {
            animateCheckmark()
        }
    }
    
    private func animateCheckmark() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(0.1)) {
            checkmarkScale = 1
        }
    }
}

struct NotificationViewReject: View {
    let message: String
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkStrokeEnd: CGFloat = 0
    
    var body: some View {
        HStack {
            Text(message)
                .font(Font.custom("helvetica", size: 15))
                .foregroundColor(Color.red)
            
            Spacer()
            
            AnimatedCheckmarkReject()
                .frame(width: 20, height: 20)
                .scaleEffect(checkmarkScale)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding(.horizontal)
        .onAppear {
            animateCheckmark()
        }
    }
    
    private func animateCheckmark() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(0.1)) {
            checkmarkScale = 1
        }
    }
}


struct AnimatedCheckmark: View {
    @State private var strokeEnd: CGFloat = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            Circle()
                .fill(skyBlueColor.skyBlue.opacity(0.2))
            
            CheckmarkShape()
                .trim(from: 0, to: strokeEnd)
                .stroke(skyBlueColor.skyBlue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                strokeEnd = 1
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0).delay(0.3)) {
                scale = 1.2
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0).delay(0.5)) {
                scale = 1
            }
        }
    }
}

struct AnimatedCheckmarkReject: View {
    @State private var strokeEnd: CGFloat = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red.opacity(0.2))
            
            XMarkShape()
                .trim(from: 0, to: strokeEnd)
                .stroke(Color.red, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                strokeEnd = 1
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0).delay(0.3)) {
                scale = 1.2
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0).delay(0.5)) {
                scale = 1
            }
        }
    }
}

// Image loader that handles fetching from company collection
class FirebaseImageLoader: ObservableObject {
    @Published var images: [String: UIImage] = [:]
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    func loadImage(from companyId: String, completion: @escaping (UIImage?) -> Void) {
        // Check if image is already cached
        if let cachedImage = images[companyId] {
            completion(cachedImage)
            return
        }
        
        // Get company document from companies collection
        let companyRef = db.collection("companies").document(companyId)
        
        companyRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching company document: \(error)")
                completion(nil)
                return
            }
            
            guard let document = document,
                  let data = document.data(),
                  let logoUrl = data["company_logo"] as? String else {
                print("No logo URL found in company document")
                completion(nil)
                return
            }
            
            // If it's a Firebase Storage path, get the download URL first
            if logoUrl.hasPrefix("gs://") || logoUrl.contains("firebasestorage.googleapis.com") {
                let storageRef = self?.storage.reference(forURL: logoUrl)
                storageRef?.downloadURL { url, error in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "")")
                        completion(nil)
                        return
                    }
                    
                    self?.downloadImage(from: downloadURL.absoluteString, companyId: companyId, completion: completion)
                }
            } else {
                // If it's already a direct URL, use it
                self?.downloadImage(from: logoUrl, companyId: companyId, completion: completion)
            }
        }
    }
    
    private func downloadImage(from urlString: String, companyId: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Error creating image from data")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.images[companyId] = image
                completion(image)
            }
        }.resume()
    }
}

// Company Logo View Component
struct CompanyLogoView: View {
    let companyId: String
    @ObservedObject var imageLoader: FirebaseImageLoader
    @State private var image: UIImage?
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image("") // Fallback image
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        imageLoader.loadImage(from: companyId) { loadedImage in
                            self.image = loadedImage
                        }
                    }
            }
        }
    }
}


struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        
        var path = Path()
        path.move(to: CGPoint(x: width * 0.28, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.3))
        
        return path
    }
}

struct XMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        
        var path = Path()
        
        // Draw the first diagonal line (top-left to bottom-right)
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.2))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.8))
        
        // Draw the second diagonal line (top-right to bottom-left)
        path.move(to: CGPoint(x: width * 0.8, y: height * 0.2))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.8))
        
        return path
    }
}



struct SimilarityResponse: Codable {
    let similarity: Double
}

#Preview {
    Home()
        .environmentObject(UserManager())
        .environmentObject(AuthService())
}

