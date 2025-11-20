import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct JobGridView: View {
    @State private var selectedJob: HostJob? = nil
    @State private var selectedCompany: HostJob? = nil
    @State private var isLoading = false
    @State private var isSheetActive = false
    @State private var isCompanyViewActive = false
    @State private var notificationState: NotificationState?
    @State private var appliedJobs: Set<String> = []
    @State private var savedJobs: Set<String> = []
    @State private var removedJobs: Set<String> = []
    @State private var hasInitialLoad = false
    
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var jobManager: JobManager
    @StateObject private var imageLoader = FirebaseImageLoader()
    
    // 2x2 grid with minimal spacing
    private let columns = [
        GridItem(.flexible(), spacing: 25),
        GridItem(.flexible(), spacing: 25)
    ]
    
    struct NotificationState {
        let message: String
        let isError: Bool
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            contentView
            
            if let state = notificationState {
                VStack {
                    Spacer()
                    NotificationBanner(
                        message: state.message,
                        type: state.isError ? .error : .success
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
                .padding(.bottom, 32)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: notificationState != nil)
            }
        }
        .onAppear {
            if !hasInitialLoad {
                isLoading = true
                loadSavedJobsFromAuth() // sync, run immediately

                Task {
                    await jobManager.loadJobsForCurrentUser()
                    await MainActor.run {
                        hasInitialLoad = true
                        isLoading = false
                    }
                }
            }
        }
        .onChange(of: selectedJob) { newJob in
            if newJob != nil {
                isSheetActive = true
            }
        }
        .onChange(of: selectedCompany) { newCompany in
            if newCompany != nil {
                isCompanyViewActive = true
            }
        }
        .sheet(isPresented: Binding<Bool>(
            get: { selectedJob != nil && isSheetActive },
            set: { if !$0 {
                selectedJob = nil
                isSheetActive = false
            }}
        )) {
            if let job = selectedJob {
                JobDetailSheet(
                    job: job,
                    onApply: {
                        await handleApplyJob(for: job)
                        if let id = job.id {
                            await MainActor.run {
                                jobManager.jobs.removeAll { $0.id == id }
                            }
                        }
                    },
                    onReject: { await handleRejectJob(for: job) },
                    isApplied: appliedJobs.contains(job.id ?? "")
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .navigationDestination(isPresented: Binding<Bool>(
            get: { selectedCompany != nil && isCompanyViewActive },
            set: { if !$0 {
                selectedCompany = nil
                isCompanyViewActive = false
            }}
        )) {
            if let company = selectedCompany {
                CompanyView(job: company, appliedJobs: $appliedJobs)
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            VStack {
                Spacer()
                ProgressView("Loading opportunities...")
                    .tint(.blue)
                    .foregroundColor(.secondary)
                Spacer()
            }
        } else if jobManager.jobs.isEmpty {
            noMoreJobsView
        } else {
            jobGrid
        }
    }
    
    private var jobGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(jobManager.jobs) { job in
                    if !removedJobs.contains(job.id ?? "") {
                        ModernJobCard(
                            job: job,
                            imageLoader: imageLoader,
                            onViewDetails: { selectedJob = job },
                            onCompanyTap: { selectedCompany = job },
                            onQuickApply: {
                                Task { await handleApplyJobWithAnimation(for: job) }
                            },
                            onSaveJob: {
                                Task { await handleSaveJobWithAnimation(for: job) }
                            },
                            isSaved: savedJobs.contains(job.id ?? ""),
                            isApplied: appliedJobs.contains(job.id ?? "")
                        )
                        .drawingGroup() // ✅ Improve rendering perf
                    }
                }
            }
            .transaction { $0.animation = nil } // ✅ Prevent excessive animation redraws
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }

    
    // MARK: - Apply Job Animation
    
    private func handleApplyJobWithAnimation(for job: HostJob) async {
        guard
            let jobId  = job.id,
            let userId = authService.currentUser?.id,
            Auth.auth().currentUser != nil
        else {
            await MainActor.run {
                notificationState = NotificationState(
                    message: "You must be signed in to apply",
                    isError: true
                )
            }
            return
        }

        // Immediate UI feedback
        appliedJobs.insert(jobId)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            removedJobs.insert(jobId)
        }

        // Firestore batch update
        do {
            let db = Firestore.firestore()
            let batch = db.batch()

            let jobRef = db.collection("jobs").document(jobId)
            let applicantEntry: [String: Any] = [
                "applicant": db.document("jobseekers/\(userId)"),
                "comments": [],
                "date_applied": Timestamp(),
                "percentage_match": 0.68,
                "round": 1,
                "status": "incomplete"
            ]
            batch.updateData([
                "job_applicants": FieldValue.arrayUnion([applicantEntry])
            ], forDocument: jobRef)

            let seekerRef = db.collection("jobseekers").document(userId)
            let jobDocRef = db.document("jobs/\(jobId)")
            batch.updateData([
                "jobs_applied": FieldValue.arrayUnion([jobDocRef])
            ], forDocument: seekerRef)

            try await batch.commit()

            await MainActor.run {
                jobManager.jobs.removeAll { $0.id == jobId }
            }
        }
        catch {
            await MainActor.run {
                appliedJobs.remove(jobId)
                removedJobs.remove(jobId)
                notificationState = NotificationState(
                    message: "Failed to apply. Please try again.",
                    isError: true
                )
            }
        }
    }

    // MARK: - Save Job Animation (Fixed)
    
    private func handleSaveJobWithAnimation(for job: HostJob) async {
        guard
            let jobId = job.id,
            let userId = authService.currentUser?.id,
            Auth.auth().currentUser != nil
        else {
            await MainActor.run {
                notificationState = NotificationState(
                    message: "You must be signed in to save jobs",
                    isError: true
                )
            }
            return
        }
        
        let db = Firestore.firestore()
        let jobRef = db.collection("jobs").document(jobId)
        let wasAlreadySaved = savedJobs.contains(jobId)
        
        // Immediate UI feedback with animation
        await MainActor.run {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                if wasAlreadySaved {
                    savedJobs.remove(jobId)
                } else {
                    savedJobs.insert(jobId)
                }
            }
        }
        
        // Update Firestore in background
        do {
            let seekerRef = db.collection("jobseekers").document(userId)
            
            if wasAlreadySaved {
                // Remove from saved jobs
                try await seekerRef.updateData([
                    "saved_jobs": FieldValue.arrayRemove([jobRef])
                ])
                
                // Update AuthService
                await MainActor.run {
                    authService.saved_jobs.removeAll { $0.documentID == jobId }
                    
                    notificationState = NotificationState(
                        message: "Removed from saved jobs 💫",
                        isError: false
                    )
                }
            } else {
                // Add to saved jobs
                try await seekerRef.updateData([
                    "saved_jobs": FieldValue.arrayUnion([jobRef])
                ])
                
                // Update AuthService
                await MainActor.run {
                    authService.saved_jobs.append(jobRef)
                    
                    notificationState = NotificationState(
                        message: "Job saved successfully ⭐",
                        isError: false
                    )
                }
            }
        } catch {
            print("Save job error: \(error.localizedDescription)")
            
            // Revert UI changes on error
            await MainActor.run {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if wasAlreadySaved {
                        savedJobs.insert(jobId)
                        authService.saved_jobs.append(jobRef)
                    } else {
                        savedJobs.remove(jobId)
                        authService.saved_jobs.removeAll { $0.documentID == jobId }
                    }
                }
                
                notificationState = NotificationState(
                    message: "Failed to save job. Please try again.",
                    isError: true
                )
            }
        }
        
        // Auto-hide notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.notificationState = nil
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadSavedJobsFromAuth() {
        savedJobs = Set(authService.saved_jobs.map { $0.documentID })
    }
    
    private func handleApplyJob(for job: HostJob) async {
        guard let jobId = job.id else { return }
        
        appliedJobs.insert(jobId)
        
        notificationState = NotificationState(
            message: "Applied to \(job.job_title ?? "Job")",
            isError: false
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.notificationState = nil
            }
        }
    }
    
    private func handleRejectJob(for job: HostJob) async {
        // Implementation to be added
    }
    
    private var noMoreJobsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.blue)
                    )
                
                VStack(spacing: 8) {
                    Text("No opportunities yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("New job matches will appear here\nwhen they become available")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Updated Modern Job Card Component
struct ModernJobCard: View {
    let job: HostJob
    let imageLoader: FirebaseImageLoader
    let onViewDetails: () -> Void
    let onCompanyTap: () -> Void
    let onQuickApply: () -> Void
    let onSaveJob: () -> Void
    let isSaved: Bool
    let isApplied: Bool
    @State private var isApplying = false
    @State private var showAppliedState = false
    @State private var saveButtonScale: CGFloat = 1.0
    @State private var applyButtonScale: CGFloat = 1.0
    @State private var checkmarkScale: CGFloat = 0.1
    @State private var progressWidth: CGFloat = 0.0
    @State private var starRotation: Double = 0.0
    @State private var starScale: CGFloat = 1.0
    @State private var isProcessingSave = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Single card container with fixed layout
        VStack(alignment: .leading, spacing: 12) {
            companyHeader
            jobDetails
            skillTags
            Spacer(minLength: 0) // Push buttons to bottom with minimum space
            actionButtons
        }
        .frame(width: 180, height: 280) // Fixed vertical rectangle size
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 0.5)
        )
        .shadow(
            color: colorScheme == .dark ? .clear : .black.opacity(0.04),
            radius: 8,
            x: 0,
            y: 2
        )
        .onTapGesture {
            onViewDetails()
        }
    }
    
    // MARK: - Card Components
    
    @ViewBuilder
    private var companyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row with logo and save button
            HStack(alignment: .top) {
                // Company logo - now tappable
                Button(action: onCompanyTap) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(companyInitials)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.blue)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // MARK: - Enhanced Save Button with Improved Animation
                Button(action: {
                    guard !isProcessingSave else { return }
                    
                    isProcessingSave = true
                    
                    // Immediate responsive feedback
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
                        saveButtonScale = 0.85
                        starScale = 0.7
                    }
                    
                    // Quick bounce back with rotation for visual feedback
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            saveButtonScale = 1.1
                            starScale = 1.2
                            starRotation += isSaved ? -360 : 360
                        }
                    }
                    
                    // Settle to final state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            saveButtonScale = 1.0
                            starScale = 1.0
                            isProcessingSave = false
                        }
                    }
                    
                    onSaveJob()
                }) {
                    ZStack {
                        // Background circle with enhanced state indication
                        Circle()
                            .fill(
                                isSaved ?
                                Color.orange.opacity(0.2) :
                                Color.gray.opacity(colorScheme == .dark ? 0.15 : 0.08)
                            )
                            .frame(width: 28, height: 28)
                            .scaleEffect(saveButtonScale)
                        
                        // Pulse effect for saved state
                        if isSaved {
                            Circle()
                                .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
                                .frame(width: 28, height: 28)
                                .scaleEffect(1.2)
                                .opacity(0.6)
                                .animation(.easeOut(duration: 0.8).repeatForever(autoreverses: true), value: isSaved)
                        }
                        
                        // Star icon with smooth transition and rotation
                        Image(systemName: isSaved ? "star.fill" : "star")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isSaved ? .orange : .secondary)
                            .scaleEffect(starScale)
                            .rotationEffect(.degrees(starRotation))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isProcessingSave)
                .offset(x: 8)
            }
            
            // Job title and company info below logo
            VStack(alignment: .leading, spacing: 4) {
                Text(job.job_title ?? "Position")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(job.company_name ?? "Company")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private var jobDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Location
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Text(job.job_location ?? "")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                if let salary = job.job_pay {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign")
                            .font(.system(size: 11))
                            .foregroundColor(.black)
                        
                        Text(salary) // Direct string display
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var skillTags: some View {
        let skills = job.job_skills ?? []
        let maxVisible = 3
        let visibleSkills = Array(skills.prefix(maxVisible))
        let extraCount = skills.count - maxVisible

        if !visibleSkills.isEmpty {
            VStack(spacing: 6) {
                // First row
                HStack(spacing: 6) {
                    if visibleSkills.count > 0 {
                        skillTag(visibleSkills[0])
                    }
                    
                    if visibleSkills.count > 1 {
                        skillTag(visibleSkills[1])
                    }
                    
                    Spacer()
                }
                
                // Second row
                HStack(spacing: 6) {
                    if visibleSkills.count > 2 {
                        skillTag(visibleSkills[2])
                    }
                    
                    // if there are more than maxVisible, show +N
                    if extraCount > 0 {
                        skillTag("+\(extraCount)")
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
    }
    
    // Helper function for consistent skill tag styling
    private func skillTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.pink.opacity(0.5),
                                Color.purple.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.pink.opacity(0.2), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Enhanced Apply Animation with Progress Bar
    @MainActor
    private func performApplyAnimation() async {
        // Step 1: Button press animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
            applyButtonScale = 0.96
            isApplying = true
        }
        
        // Brief delay for button press effect
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Step 2: Return to normal size and start progress bar
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            applyButtonScale = 1.0
        }
        
        // Step 3: Animate progress bar filling up
        withAnimation(.easeInOut(duration: 1.2)) {
            progressWidth = 1.0
        }
        
        // Wait for progress bar to complete
        try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds
        
        // Step 4: Transform to applied state with pink gradient
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isApplying = false
            showAppliedState = true
            checkmarkScale = 1.0
            progressWidth = 0.0 // Reset progress for next use
        }
        
        // Step 5: Brief pause then trigger removal
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        // Step 6: Trigger the card removal animation
        onQuickApply()
    }

    // MARK: - Enhanced Apply Button with Progress Bar
    private var actionButtons: some View {
        VStack {
            Button(action: {
                Task {
                    await performApplyAnimation()
                }
            }) {
                ZStack {
                    // Background rectangle
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            showAppliedState ?
                            AnyShapeStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.pink.opacity(0.8),
                                        Color.purple.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            ) :
                            AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                        .frame(height: 36)
                        .scaleEffect(applyButtonScale)
                    
                    // Progress bar overlay (only shown when applying)
                    if isApplying {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.3),
                                        Color.cyan.opacity(0.2)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 36)
                            .scaleEffect(x: progressWidth, y: 1.0, anchor: .leading)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Content Animation
                    HStack(spacing: 8) {
                        if showAppliedState {
                            // Success state with expanding checkmark
                            ZStack {
                                // Expanding circle background
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 18, height: 18)
                                    .scaleEffect(checkmarkScale)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                                            .scaleEffect(checkmarkScale * 1.3)
                                            .opacity(1 - checkmarkScale)
                                    )
                                
                                // Checkmark with draw-in effect
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.pink)
                                    .scaleEffect(checkmarkScale)
                                    .rotationEffect(.degrees(checkmarkScale < 1 ? -180 : 0))
                            }
                            
                            Text("Applied")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        } else if isApplying {
                            // Loading state with small progress line
                            HStack(spacing: 8) {
                                // Small progress line
                                ZStack {
                                    // Background line
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 24, height: 2)
                                    
                                    // Animated progress fill
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.white)
                                        .frame(width: 24 * progressWidth, height: 2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(width: 24)
                                
                                Text("Sending...")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        } else {
                            // Default state
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Apply")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .disabled(isApplied || isApplying)
            .onAppear {
                showAppliedState = isApplied
                checkmarkScale = isApplied ? 1.0 : 0.1
                progressWidth = 0.0 // Ensure progress starts at 0
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 5)
    }
    
    // MARK: - Computed Properties
    
    private var borderColor: Color {
        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    private var companyInitials: String {
        if let companyName = job.company_name {
            let words = companyName.components(separatedBy: .whitespacesAndNewlines)
            if words.count >= 2 {
                return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
            } else {
                return String(companyName.prefix(2)).uppercased()
            }
        }
        return "??"
    }
    
    // MARK: - Helper Methods
    
    private func formatSalary(_ salary: String?) -> String {
        return salary ?? "Not specified"
    }
}

// MARK: - Modern Colorful Company View
struct CompanyView: View {
    let job: HostJob
    let company: CompanyInfo? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showingJobSheet = false
    @Binding var appliedJobs: Set<String>
    
    var body: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.01)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                    
                    // Main Content
                    VStack(spacing: 40) {
                        // Company Stats
                        companyStatsSection
                        
                        // About Section
                        aboutSection
                        
                        // Current Openings
                        currentOpeningsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
            }
        }
        .sheet(isPresented: $showingJobSheet) {
            JobDetailSheet(
                job: job,
                onApply: {
                    // Handle apply action
                },
                onReject: {
                    // Handle reject action
                },
                isApplied: appliedJobs.contains(job.id ?? "") 
            )
        }
    }
    
    // MARK: - Hero Section
    @ViewBuilder
    private var heroSection: some View {
        VStack(spacing: 28) {
            // Colorful Company Logo
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.12),
                                Color.purple.opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                    )
                
                Text(companyInitials)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
            }
            .shadow(color: Color.blue.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Company Info
            VStack(spacing: 16) {
                Text(job.company_name ?? "Company")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                // Location with gradient background
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text(job.job_location ?? "Remote")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.06))
                        .overlay(
                            Capsule()
                                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 50)
        .padding(.bottom, 50)
    }
    
    // MARK: - Company Stats Section
    @ViewBuilder
    private var companyStatsSection: some View {
        VStack(spacing: 20) {
            // Stats grid with colorful cards
            HStack(spacing: 16) {
                // Company Type
                statCard(
                    title: "Type",
                    value: company?.company_type ?? "Technology",
                    color: .blue,
                    icon: "building.2.fill"
                )
                
                // Company Size
                statCard(
                    title: "Size",
                    value: company?.company_size ?? "50-200",
                    color: .green,
                    icon: "person.3.fill"
                )
            }
            
            // Website Link with colorful design
            let website = company?.company_website ?? ""

            Button(action: {
                // Handle website tap
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "globe")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text(website)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.04),
                                    Color.purple.opacity(0.02)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - About Section
    @ViewBuilder
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Mission
            if let mission = company?.company_mission {
                sectionContainer(title: "Mission", icon: "target", color: .purple) {
                    Text(mission)
                        .font(.system(size: 16, weight: .regular))
                        .lineSpacing(6)
                        .foregroundColor(.primary)
                }
            }
            
            // Description
            sectionContainer(title: "About", icon: "info.circle.fill", color: .blue) {
                Text(company?.company_description ?? job.about_the_job ?? "We're building the future of technology with innovative solutions and a passionate team.")
                    .font(.system(size: 16, weight: .regular))
                    .lineSpacing(6)
                    .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Current Openings Section
    @ViewBuilder
    private var currentOpeningsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Current Openings")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("1 position")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            
            // Colorful Job Card
            VStack(spacing: 0) {
                // Job Header
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(job.job_title ?? "Software Engineer")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            Label(job.employment_type ?? "Full-time", systemImage: "briefcase.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            if let salary = job.job_pay {
                                Label(salary, systemImage: "dollarsign.circle.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    // Skills with new gradient design
                    if let skills = job.job_skills, !skills.isEmpty {
                        let displaySkills = Array(skills.prefix(5))
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), alignment: .leading),
                            GridItem(.flexible(), alignment: .leading),
                            GridItem(.flexible(), alignment: .leading)
                        ], alignment: .leading, spacing: 3) {
                            ForEach(Array(displaySkills.enumerated()), id: \.offset) { index, skill in
                                skillTag(skill)
                            }
                            
                            if skills.count > 5 {
                                Text("+\(skills.count - 5)")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.pink.opacity(0.5),
                                                        Color.purple.opacity(0.4)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: Color.pink.opacity(0.2), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Colorful Apply Button
                Button(action: {
                    showingJobSheet = true
                }) {
                    HStack {
                        Text("Apply Now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue,
                                        Color.blue.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            )
        }
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    private func statCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func sectionContainer<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(color.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    // MARK: - New Skill Tag Function
    private func skillTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.pink.opacity(0.5),
                                Color.purple.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.pink.opacity(0.2), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    private var companyInitials: String {
        if let companyName = job.company_name {
            let words = companyName.components(separatedBy: .whitespacesAndNewlines)
            if words.count >= 2 {
                return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
            } else {
                return String(companyName.prefix(2)).uppercased()
            }
        }
        return "??"
    }
    
    private func formatCompanySalary(_ salary: String) -> String {
        return salary // Since it's already a formatted string
    }
}


struct JobDetailSheet: View {
    let job: HostJob
    let onApply: () async -> Void
    let onReject: () async -> Void
    let isApplied: Bool
    
    // Add these state variables for the animation
    @State private var isApplying = false
    @State private var showAppliedState = false
    @State private var applyButtonScale: CGFloat = 1.0
    @State private var checkmarkScale: CGFloat = 0.1
    @State private var progressWidth: CGFloat = 0.0
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            contentScrollView
            applyButtonSection
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // Break up the ScrollView into its own computed property
    private var contentScrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                contentSection
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // Header section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Job Details")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                let jobTitle = job.job_title ?? "Job"
                let company = job.company_name ?? "Company"
                let message = "Check out this opportunity: \(jobTitle) at \(company)."
                
                let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(activityVC, animated: true, completion: nil)
                }
            }) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    // Content section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            jobHeaderCard
            
            if let description = job.about_the_job {
                jobDescriptionSection(description: description)
            }
            
            jobDetailsGrid
            
            if let benefits = job.job_benefits, !benefits.isEmpty {
                benefitsSection(benefits: benefits)
            }
            
            if let requirements = job.job_requirements, !requirements.isEmpty {
                requirementsSection(requirements: requirements)
            }
            
            if let companyDescription = job.about_the_job, !companyDescription.isEmpty {
                DetailSection(title: "About the Company", content: companyDescription, icon: "building.2.fill", color: skyBlueColor.skyBlue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 100)
    }
    
    // Job header card
    private var jobHeaderCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(job.job_title ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(job.company_name ?? "")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(job.employment_type ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(job.job_location ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Company logo with enhanced design
                Button {
                    // Use NotificationCenter to open company view
                
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [skyBlueColor.skyBlue.opacity(0.1), skyBlueColor.skyBlue.opacity(0.05)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text(job.company_name?.prefix(2).uppercased() ?? "?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(skyBlueColor.skyBlue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Job description section
    private func jobDescriptionSection(description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About the Position")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.body)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // Job details grid
    private var jobDetailsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Job Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DetailCard(
                    icon: "dollarsign.circle.fill",
                    title: "Salary",
                    value: job.job_pay ?? "Not specified",
                    color: .green
                )
                
                DetailCard(
                    icon: "briefcase.fill",
                    title: "Type",
                    value: job.employment_type ?? "Not specified",
                    color: skyBlueColor.skyBlue
                )
                
                DetailCard(
                    icon: "location.fill",
                    title: "Location",
                    value: job.job_location ?? "Not specified",
                    color: .orange
                )
                
                DetailCard(
                    icon: "person.and.background.dotted",
                    title: "Rounds",
                    value: String(job.job_rounds ?? 0),
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // Benefits section
    private func benefitsSection(benefits: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "gift.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 16, weight: .medium))
                Text("Benefits")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(benefits, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.body)
                            .padding(.top, 2)
                        Text(item)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // Requirements section
    private func requirementsSection(requirements: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "list.bullet")
                    .foregroundColor(.orange)
                    .font(.system(size: 16, weight: .medium))
                Text("Requirements")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(requirements, id: \.self) { req in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.body)
                            .padding(.top, 2)
                        Text(req)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // Apply button section
    private var applyButtonSection: some View {
        VStack {
            Button(action: {
                Task {
                    await performApplyAnimation()
                }
            }) {
                applyButtonContent
            }
            .disabled(isApplied || isApplying)
            .onAppear {
                showAppliedState = isApplied
                checkmarkScale = isApplied ? 1.0 : 0.1
                progressWidth = 0.0
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .background(
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
    
    // Apply button content
    private var applyButtonContent: some View {
        ZStack {
            applyButtonBackground
            
            if isApplying {
                applyButtonProgressOverlay
            }
            
            applyButtonTextContent
        }
    }
    
    // Apply button background
    private var applyButtonBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                showAppliedState ?
                AnyShapeStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.pink.opacity(0.8),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                ) :
                AnyShapeStyle(
                    LinearGradient(
                        colors: [skyBlueColor.skyBlue, skyBlueColor.skyBlue.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            )
            .frame(height: 56)
            .scaleEffect(applyButtonScale)
    }
    
    // Apply button progress overlay
    private var applyButtonProgressOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        skyBlueColor.skyBlue.opacity(0.3),
                        Color.cyan.opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 56)
            .scaleEffect(x: progressWidth, y: 1.0, anchor: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // Apply button text content
    private var applyButtonTextContent: some View {
        HStack(spacing: 12) {
            if showAppliedState {
                applyButtonSuccessContent
            } else if isApplying {
                applyButtonLoadingContent
            } else {
                applyButtonDefaultContent
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // Apply button success content
    private var applyButtonSuccessContent: some View {
        Group {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .scaleEffect(checkmarkScale)
                    .overlay(
                        Circle()
                            .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                            .scaleEffect(checkmarkScale * 1.3)
                            .opacity(1 - checkmarkScale)
                    )
                
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.pink)
                    .scaleEffect(checkmarkScale)
                    .rotationEffect(.degrees(checkmarkScale < 1 ? -180 : 0))
            }
            
            Text("Applied Successfully")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    // Apply button loading content
    private var applyButtonLoadingContent: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 32, height: 3)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: 32 * progressWidth, height: 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 32)
            
            Text("Sending Application...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    // Apply button default content
    private var applyButtonDefaultContent: some View {
        Group {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Apply Now")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    // ADD THIS ANIMATION FUNCTION (same as in ModernJobCard but adapted)
    @MainActor
    private func performApplyAnimation() async {
        // Step 1: Button press animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
            applyButtonScale = 0.96
            isApplying = true
        }
        
        // Brief delay for button press effect
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Step 2: Return to normal size and start progress bar
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            applyButtonScale = 1.0
        }
        
        // Step 3: Animate progress bar filling up
        withAnimation(.easeInOut(duration: 1.2)) {
            progressWidth = 1.0
        }
        
        // Wait for progress bar to complete
        try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds
        
        // Step 4: Transform to applied state with pink gradient
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isApplying = false
            showAppliedState = true
            checkmarkScale = 1.0
            progressWidth = 0.0 // Reset progress for next use
        }
        
        // Step 5: Call the actual apply function
        await onApply()
        
        // Step 6: Brief pause to show success state
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Step 7: Dismiss the sheet
        dismiss()
    }
    
    // Keep the existing formatSalary function
    private func formatSalary(_ salary: String) -> String {
        return salary // Since it's already a formatted string
    }
}

// You'll need to add these struct definitions if they're not already in your project:

struct DetailCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                Spacer()
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
        }
        .padding(.horizontal)
        .frame(width: 155, height: 90)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


struct DetailSection: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(.body)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}



struct NotificationBanner: View {
    let message: String
    let type: NotificationType
    
    enum NotificationType {
        case success
        case error
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(type.color.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(type.color.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}
