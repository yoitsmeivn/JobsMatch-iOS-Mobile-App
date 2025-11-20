//
//  myJobs.swift
//  JobsMatch
//
//  Created by ivans Android on 6/19/24.
//

import SwiftUI
import FirebaseFirestore

struct myJobs: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = MyJobsViewModel()
    @State private var selectedTab = 0
    @State private var showingSavedJobs = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header with gradient
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("My Applications")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingSavedJobs = true }) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Stats Cards
                    if !viewModel.appliedJobs.isEmpty {
                        HStack(spacing: 12) {
                            StatsCard(
                                title: "Applied",
                                count: viewModel.appliedJobs.count,
                                icon: "doc.text.fill",
                                color: skyBlueColor.skyBlue
                            )
                            
                            StatsCard(
                                title: "Pending",
                                count: viewModel.appliedJobs.filter {
                                    $0.job_applicants?.first?.status?.lowercased() == "pending"
                                }.count,
                                icon: "clock.fill",
                                color: .yellow
                            )
                            
                            StatsCard(
                                title: "Interviews",
                                count: viewModel.appliedJobs.filter {
                                    $0.job_applicants?.first?.status?.lowercased() == "interview"
                                }.count,
                                icon: "person.2.fill",
                                color: .purple
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [skyBlueColor.skyBlue, skyBlueColor.skyBlue.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Content
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(skyBlueColor.skyBlue)
                        
                        Text("Loading your applications...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.appliedJobs.isEmpty {
                    EmptyStateView(onGetStarted: {
                        // Handle get started action
                        dismiss()
                    })
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.appliedJobs) { job in
                                NavigationLink(destination: JobDetailView(job: job)) {
                                    EnhancedJobApplicationRow(job: job)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        if let userId = authService.currentUser?.id {
                            viewModel.fetchAppliedJobs(for: userId)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSavedJobs) {
            SavedJobsView()
        }
        .onAppear {
            if let userId = authService.currentUser?.id {
                viewModel.fetchAppliedJobs(for: userId)
            }
        }
    }
}

struct StatsCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

struct EnhancedJobApplicationRow: View {
    let job: HostJob
    
    private var applicationDate: String {
        if let ts = job.job_applicants?.first?.date_applied {
            let date = ts.dateValue()             // ← convert here
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)   // now a Swift `Date`
        }
        return ""
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced Job Logo
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [skyBlueColor.skyBlue.opacity(0.1), skyBlueColor.skyBlue.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Text(job.company_name?.prefix(2).uppercased() ?? "?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(skyBlueColor.skyBlue)
            }
            
            // Job Info
            VStack(alignment: .leading, spacing: 6) {
                Text(job.job_title ?? "Unnamed Job")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(job.company_name ?? "Unknown Company")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(job.employment_type ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    if let location = job.job_location, !location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            
                            Text(location)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                StatusCapsule(
                    status: job.job_applicants?.first?.status ?? "incomplete"
                )
                
                Text(applicationDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct EmptyStateView: View {
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated illustration
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(skyBlueColor.skyBlue)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.blue.opacity(0.5))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text("No Applications Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Start your career journey by applying to jobs that match your skills and interests")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button(action: onGetStarted) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Explore Jobs")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [skyBlueColor.skyBlue, skyBlueColor.skyBlue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

// Enhanced Status Capsule
struct StatusCapsule: View {
    let status: String
    
    var statusConfig: (color: Color, text: String) {
        switch status.lowercased() {
        case "accepted":
            return (Color.green.opacity(0.2), "Accepted")
        case "rejected", "denied":
            return (Color.red.opacity(0.2), "Rejected")
        case "pending":
            return (Color.blue.opacity(0.2), "Pending")
        case "interview":
            return (Color.purple.opacity(0.2), "Interview")
        case "incomplete":
            return (Color.yellow.opacity(0.2), "Incomplete")
        default:
            return (Color.gray.opacity(0.2), "Applied")
        }
    }
    
    var textColor: Color {
        switch status.lowercased() {
        case "accepted":
            return Color.green
        case "rejected", "denied":
            return Color.red
        case "pending":
            return skyBlueColor.skyBlue
        case "interview":
            return Color.purple
        case "incomplete":
            return Color.orange
        default:
            return Color.gray
        }
    }
    
    var body: some View {
        Text(statusConfig.text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusConfig.color)
            .clipShape(Capsule())
    }
}

// Job Detail View (Updated to match JobDetailSheet functionality)
struct JobDetailView: View {
    @Environment(\.dismiss) var dismiss
    let job: HostJob
    
    private var applicationDate: String {
        if let ts = job.job_applicants?.first?.date_applied {
            let date = ts.dateValue()             // ← convert here
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)   // now a Swift `Date`
        }
        return ""
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
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
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Job Header Card
                    VStack(spacing: 20) {
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
                        
                        // Status with application date
                        HStack {
                            StatusCapsule(
                                status: job.job_applicants?.first?.status ?? "Applied"
                            )
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Applied")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(applicationDate)
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                    
                    // Description
                    if let description = job.about_the_job {
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
                    
                    // Details Grid
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
                                icon: "gift.fill",
                                title: "Benefits",
                                value: job.job_benefits?.isEmpty == false ? "Available" : "Not specified",
                                color: .purple
                            )
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    
                    // Benefits and Requirements
                    if let benefits = job.job_benefits, !benefits.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.purple)
                                Text("Benefits")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(benefits, id: \.self) { benefit in
                                    HStack(alignment: .top, spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.purple)
                                        Text(benefit)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    }
                    
                    
                    // About the Company
                    if let companyDescription = job.about_the_job, !companyDescription.isEmpty {
                        DetailSection(title: "About the Company", content: companyDescription, icon: "building.2.fill", color: skyBlueColor.skyBlue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
    
    private func formatSalary(_ salary: Int?) -> String {
        guard let salary = salary else { return "Not specified" }
        
        if salary >= 100000 {
            return "$\(salary/1000)K per year"
        } else if salary >= 1000 {
            return "$\(salary/1000)K per year"
        } else {
            return "$\(salary) per hour"
        }
    }
}



// Placeholder for Saved Jobs View
struct SavedJobsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Saved Jobs")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your saved jobs will appear here")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Saved Jobs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Keep your existing MyJobsViewModel class unchanged
class MyJobsViewModel: ObservableObject {
    @Published var appliedJobs: [HostJob] = []
    @Published var acceptedJobs: [HostJob] = []
    @Published var deniedJobs: [HostJob] = []
    @Published var isLoading = false
    private var db = Firestore.firestore()
    
    func fetchAppliedJobs(for user_id: String) {
        isLoading = true
        let userRef = db.collection("jobseekers").document(user_id)
        
        db.collection("jobs")
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("Error getting documents: \(error)")
                        return
                    }
                    
                    self.appliedJobs = querySnapshot?.documents.compactMap { document -> HostJob? in
                        let data = document.data()
                        // Check if job_applicants array contains an entry with matching applicant
                        if let applicants = data["job_applicants"] as? [[String: Any]] {
                            let hasApplied = applicants.contains { applicant in
                                if let applicantRef = applicant["applicant"] as? DocumentReference {
                                    return applicantRef.path == userRef.path
                                }
                                return false
                            }
                            
                            if hasApplied {
                                return HostJob.decode(data: data, id: document.documentID)
                            }
                        }
                        return nil
                    } ?? []
                    
                    print("Fetched \(self.appliedJobs.count) applied jobs")
                }
            }
    }
    
    func fetchAcceptedJobs(for user_id: String) {
        isLoading = true
        let userRef = db.collection("jobseekers").document(user_id)
        
        db.collection("jobs")
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("Error getting documents: \(error)")
                        return
                    }
                    
                    self.acceptedJobs = querySnapshot?.documents.compactMap { document -> HostJob? in
                        let data = document.data()
                        // Check if user's reference exists in applicants_accepted array
                        if let acceptedApplicants = data["applicants_accepted"] as? [[String: Any]] {
                            let isAccepted = acceptedApplicants.contains { applicant in
                                if let applicantRef = applicant["applicant"] as? DocumentReference {
                                    return applicantRef.path == userRef.path
                                }
                                return false
                            }
                            
                            if isAccepted {
                                return try? document.data(as: HostJob.self)
                            }
                        }
                        return nil
                    } ?? []
                }
            }
    }

    func fetchDeniedJobs(for user_id: String) {
        isLoading = true
        let userRef = db.collection("jobseekers").document(user_id)
        
        db.collection("jobs")
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("Error getting documents: \(error)")
                        return
                    }
                    
                    self.deniedJobs = querySnapshot?.documents.compactMap { document -> HostJob? in
                        let data = document.data()
                        // Check if user's reference exists in applicants_denied array
                        if let deniedApplicants = data["applicants_denied"] as? [[String: Any]] {
                            let isDenied = deniedApplicants.contains { applicant in
                                if let applicantRef = applicant["applicant"] as? DocumentReference {
                                    return applicantRef.path == userRef.path
                                }
                                return false
                            }
                            
                            if isDenied {
                                return try? document.data(as: HostJob.self)
                            }
                        }
                        return nil
                    } ?? []
                }
            }
    }
}

#Preview {
    myJobs()
        .environmentObject(AuthService())
}
