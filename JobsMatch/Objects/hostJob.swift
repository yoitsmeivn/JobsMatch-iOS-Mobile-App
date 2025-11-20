//
//  hostJob.swift
//  JobsMatch
//
//  Created by ivans Android on 5/20/24.
//

import UIKit
import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestore

struct UserApplication: Hashable, Codable {
    var round: Int?
    var applicant: DocumentReference?
    var status: String?
    var comments: [String]?
    var date_applied: Timestamp?
    var percentage_match: Double?
    
    enum CodingKeys: String, CodingKey {
        case round, applicant, _status = "status", comments, date_applied, percentage_match
    }
    
    init(
         round: Int? = nil,
         applicant: DocumentReference?,
         status: String? = "",
         comments: [String]? = nil,
         date_applied: Timestamp? = nil,
         percentage_match: Double? = nil) {
        self.round = round
        self.applicant = applicant
        self.status = status
        self.comments = comments
        self.date_applied = date_applied
        self.percentage_match = percentage_match
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(round, forKey: .round)
        try container.encode(applicant, forKey: .applicant)  // Encode the reference directly
        try container.encode(status, forKey: ._status)
        try container.encodeIfPresent(comments, forKey: .comments)
        try container.encodeIfPresent(date_applied, forKey: .date_applied)
        try container.encodeIfPresent(percentage_match, forKey: .percentage_match)
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        round = try container.decodeIfPresent(Int.self, forKey: .round)
        applicant = try container.decodeIfPresent(DocumentReference.self, forKey: .applicant)  // Decode as DocumentReference
        //        status = try container.decodeIfPresent(String.self, forKey: ._status)
        comments = try container.decodeIfPresent([String].self, forKey: .comments)
        date_applied = try container.decodeIfPresent(Timestamp.self, forKey: .date_applied)
        percentage_match = try container.decodeIfPresent(Double.self, forKey: .percentage_match)
    }
    
    private static func decode(data: [String : Any]) -> UserApplication? {
        let round = data["round"] as? Int
        let applicant = data["applicant"] as? DocumentReference
        let status = data["status"] as? String
        let comments = data["comments"] as? [String]
        let date_applied = data["date_applied"] as? Timestamp
        let percentage_match = data["percentage_match"] as? Double
        
        return UserApplication(
            round: round,
            applicant: applicant,
            status: status,
            comments: comments,
            date_applied: date_applied,
            percentage_match: percentage_match
        )
    }
    
    static func decodeUserApplications(data: [String : Any], key: String) -> [UserApplication] {
        
        guard let applicants = data[key] as? [[String : Any]] else { return [] }
        
        var applications: [UserApplication] = []
        for applicationData in applicants {
            if let application = UserApplication.decode(data: applicationData) {
                applications.append(application)
            }
        }
        
        return applications
    }
}



struct CompanyInfo: Identifiable, Hashable, Codable{
    internal init(id: String? = nil, company_id: DocumentReference? = nil, company_reg_id: String? = nil, company_name: String? = nil, company_tax_id: String? = nil, company_ein: String? = nil, company_type: String? = nil, company_size: String? = nil, company_eligibility: String? = nil,company_email: String? = nil,company_website: String? = nil,company_phone: String? = nil, company_logo: String? = nil, company_description: String? = nil, company_mission: String? = nil, company_address: String? = nil, company_city: String? = nil, company_zipcode: String? = nil, last_req_id: String? = nil,  company_jobs: [DocumentReference]? = nil){
        
        self.id = id
        self.company_id = company_id
        self.company_reg_id = company_reg_id
        self.company_name = company_name
        self.company_tax_id = company_tax_id
        self.company_ein = company_ein
        self.company_type = company_type
        self.company_size = company_size
        self.company_eligibility = company_eligibility
        self.company_email = company_email
        self.company_website = company_website
        self.company_phone = company_phone
        self.company_logo = company_logo
        self.company_description = company_description
        self.company_mission = company_mission
        self.company_address = company_address
        self.company_city = company_city
        self.company_zipcode = company_zipcode
        self.last_req_id = last_req_id
        self.company_jobs = company_jobs
        
    }
    
    @DocumentID var id: String?
    var company_id: DocumentReference?
    var company_reg_id: String?
    var company_name: String?
    var company_tax_id: String?
    var company_ein: String?
    var company_type: String?
    var company_size: String?
    var company_eligibility: String?
    var company_email: String?
    var company_website: String?
    var company_phone: String?
    var company_logo: String?
    var company_description: String?
    var company_mission: String?
    var company_address: String?
    var company_city: String?
    var company_zipcode: String?
    var last_req_id: String?
    var company_jobs: [DocumentReference]?
    
    // MARK: - Equatable & Hashable
    static func == (lhs: CompanyInfo, rhs: CompanyInfo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func decode(data: [String : Any], id: String) -> CompanyInfo {
        
        let company_id = data["company_id"] as? DocumentReference
        let company_reg_id = data["company_reg_id"] as? String
        let company_name = data["company_name"] as? String
        let company_tax_id = data["company_tax_id"] as? String
        let company_ein = data["company_ein"] as? String  // Changed back to DocumentReferenc
        let company_type = data["company_type"] as? String
        let company_size = data["company_size"] as? String
        let company_eligibility = data["company_eligibility"] as? String
        let company_email = data["company_email"] as? String
        let company_website = data["company_website"] as? String
        let company_phone = data["company_phone"] as? String
        let company_logo = data["company_logo"] as? String
        let company_description = data["company_description"] as? String
        let company_mission = data["company_mission"] as? String
        let company_address = data["company_address"] as? String
        let company_city = data["company_city"] as? String
        let company_zipcode = data["company_zipcode"] as? String
        let last_req_id = data["last_req_id"] as? String
        let company_jobs = data["company_jobs"] as? [DocumentReference]
        
        return CompanyInfo(
            id: id,
            company_id: company_id,
            company_reg_id: company_reg_id,
            company_name: company_name,
            company_tax_id: company_tax_id,
            company_ein: company_ein,
            company_type: company_type,
            company_size: company_size,
            company_eligibility: company_eligibility,
            company_email: company_email,
            company_website: company_website,
            company_phone: company_phone,
            company_logo: company_logo,
            company_description: company_description,
            company_mission: company_mission,
            company_address: company_address,
            company_city: company_city,
            company_zipcode: company_zipcode,
            last_req_id: last_req_id,
            company_jobs: company_jobs
            
        )
    }
}

struct HostJob: Identifiable, Hashable, Codable {
    internal init(id: String? = nil, job_req_id: String? = nil, job_title: String? = nil, company_id: DocumentReference? = nil, company_name: String? = nil, job_creator: DocumentReference? = nil, job_location: String? = nil, employment_type: String? = nil, date_posted: Timestamp? = nil, is_salary: Bool? = nil, about_the_job: String? = nil, job_requirements: [String]? = nil, job_benefits: [String]? = nil, job_pay: String? = nil, job_applicants: [UserApplication]? = nil, applicants_denied: [UserApplication]? = nil, applicants_accepted: [UserApplication]? = nil, job_rounds: Int? = nil, job_skills: [String]? = nil) {
        self.id = id
        self.job_req_id = job_req_id
        self.job_title = job_title
        self.company_id = company_id
        self.company_name = company_name
        self.job_creator = job_creator
        self.job_location = job_location
        self.employment_type = employment_type
        self.date_posted = date_posted
        self.is_salary = is_salary
        self.about_the_job = about_the_job
        self.job_requirements = job_requirements
        self.job_benefits = job_benefits
        self.job_pay = job_pay
        self.job_applicants = job_applicants
        self.applicants_denied = applicants_denied
        self.applicants_accepted = applicants_accepted
        self.job_rounds = job_rounds
        self.job_skills = job_skills
    }
    
    @DocumentID var id: String?
    var job_req_id: String?
    var job_title: String?
    var company_id: DocumentReference?  // Changed back to DocumentReference
    var company_name: String?
    var job_creator: DocumentReference?  // Changed back to DocumentReference
    var job_location: String?
    var employment_type: String?
    var date_posted: Timestamp?
    var is_salary: Bool?
    var about_the_job: String?
    var job_requirements: [String]?
    var job_benefits: [String]?
    var job_pay: String?
    var job_applicants: [UserApplication]? // Firestore: [[String:Any]]
    var applicants_denied: [UserApplication]? // Firestore: [[String:Any]]
    var applicants_accepted: [UserApplication]? // Firestore: [[String:Any]]
    var job_rounds: Int?
    var job_skills: [String]?
    
    // MARK: - Equatable & Hashable
    static func == (lhs: HostJob, rhs: HostJob) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private enum CodingKeys: String, CodingKey {
            case id, job_req_id, job_title, company_id, company_name, job_creator
            case job_location, employment_type, date_posted, is_salary
            case about_the_job, job_requirements, job_benefits, job_pay
            case job_applicants, applicants_denied, applicants_accepted
            case job_rounds, job_skills
        }
    
    static func decode(data: [String : Any], id: String) -> HostJob {
        
        let job_req_id = data["job_req_id"] as? String
        let job_title = data["job_title"] as? String
        let company_id = data["company_id"] as? DocumentReference
        let company_name = data["company_name"] as? String
        let job_creator = data["job_creator"] as? DocumentReference  // Changed back to DocumentReferenc
        let job_location = data["job_location"] as? String
        let employment_type = data["employment_type"] as? String
        let date_posted = data["date_posted"] as? Timestamp
        let is_salary = data["is_salary"] as? Bool
        let about_the_job = data["about_the_job"] as? String
        let job_requirements = data["job_requirements"] as? [String]
        let job_benefits = data["job_benefits"] as? [String]
        let job_pay = data["job_pay"] as? String
        let job_applicants = UserApplication.decodeUserApplications(data: data, key: "job_applicants")
        let applicants_denied = UserApplication.decodeUserApplications(data: data, key: "applicants_denied")
        let applicants_accepted =  UserApplication.decodeUserApplications(data: data, key: "applicants_accepted")
        let job_rounds = data["job_rounds"] as? Int
        let job_skills = data["job_skills"] as? [String]
        
        return HostJob(
            id: id,
            job_req_id: job_req_id,
            job_title: job_title,
            company_id: company_id,
            company_name: company_name,
            job_creator: job_creator,
            job_location: job_location,
            employment_type: employment_type,
            date_posted: date_posted,
            is_salary: is_salary,
            about_the_job: about_the_job,
            job_requirements: job_requirements,
            job_benefits: job_benefits,
            job_pay: job_pay,
            job_applicants: job_applicants,
            applicants_denied: applicants_denied,
            applicants_accepted: applicants_accepted,
            job_rounds: job_rounds,
            job_skills: job_skills
            
        )
    }
}


class JobManager: ObservableObject {
    @Published var jobs: [HostJob] = []
    @Published var hostJobs: [HostJob] = []
    @Published var hosts: [Host] = []
    @Published var currentJobIndex: Int = 0
    @Published var companies: [CompanyInfo] = []
    @Published var jobCards: [JobCards] = [] // Fixed to use JobCards instead of JobCard
    
    private let authService: AuthService
    private var processingJobs: Set<String> = []
    
    init(authService: AuthService) {
        self.authService = authService
        Task {
            await loadJobsForCurrentUser()
        }
    }
    
    // MARK: - Main Loading Functions
    
    func loadJobsForCurrentUser() async {
        do {
            if let userId = authService.userSession?.uid {
                fetchHosts()
                if let user = authService.fetchCurrentUser(for: userId) {
                    fetchJobsWithCompanies(for: user)
                }
            }
        }
    }
    
    func fetchJobsWithCompanies(for user: User) {
        let db = Firestore.firestore()
        
        // First fetch companies
        db.collection("companies").getDocuments { [weak self] (companySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching companies: \(error.localizedDescription)")
                return
            }
            
            // Store companies
            self.companies = companySnapshot?.documents.compactMap { doc in
                CompanyInfo.decode(data: doc.data(), id: doc.documentID)
            } ?? []
            
            print("Fetched \(self.companies.count) companies")
            
            // Then fetch jobs
            self.fetchJobs(for: user)
        }
    }
    
    // MARK: - Job Fetching
    
    func fetchJobs(for user: User) {
        let db = Firestore.firestore()
        
        guard let currentUser = authService.currentUser else { return }
        let appliedJobRefs = Set(user.jobs_applied ?? [])
        let declinedJobRefs = Set(user.jobs_declined ?? [])
        
        db.collection("jobs").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching jobs: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No jobs found.")
                return
            }
            
            let group = DispatchGroup()
            var fetchedJobs: [HostJob] = []
            
            for doc in documents {
                group.enter()
                let job = HostJob.decode(data: doc.data(), id: doc.documentID)
                let jobRef = db.collection("jobs").document(doc.documentID)
                
                // Early filtering to improve performance
                guard !appliedJobRefs.contains(jobRef),
                      !declinedJobRefs.contains(jobRef),
                      job.id != "job_schema",
                      job.job_applicants?.count ?? 0 < 100 else {
                    group.leave()
                    continue
                }
                
                // Fetch company information for each job
                if let companyRef = job.company_id {
                    companyRef.getDocument { (companyDoc, error) in
                        defer { group.leave() }
                        
                        var updatedJob = job
                        
                        if let companyData = companyDoc?.data() {
                            // Update job with company information
                            updatedJob.company_name = companyData["company_name"] as? String
                            
                            // Store additional company info that might be needed
                            if let companyLogo = companyData["company_logo"] as? String {
                                // We'll use this when creating JobCards
                            }
                        }
                        
                        fetchedJobs.append(updatedJob)
                    }
                } else {
                    group.leave()
                    fetchedJobs.append(job)
                }
            }
            
            group.notify(queue: .main) {
                // Remove duplicates and final filtering
                var uniqueJobs: [String: HostJob] = [:]
                for fetchedJob in fetchedJobs {
                    if let jobId = fetchedJob.id, uniqueJobs[jobId] == nil {
                        uniqueJobs[jobId] = fetchedJob
                    }
                }
                
                self.jobs = Array(uniqueJobs.values).filter { job in
                    let jobRef = db.collection("jobs").document(job.id ?? "")
                    return !appliedJobRefs.contains(jobRef) && !declinedJobRefs.contains(jobRef)
                }
                
                print("Fetched \(self.jobs.count) jobs for current user")
                
                // Create job cards after jobs are loaded
                self.createJobCards()
            }
        }
    }
    
    func fetchHostJobs(for host: Host) async {
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("jobs").getDocuments()
            let allJobs = querySnapshot.documents.compactMap { doc -> HostJob? in
                return HostJob.decode(data: doc.data(), id: doc.documentID)
            }
            
            // Filter jobs that belong to this host
            self.hostJobs = allJobs.filter { job in
                return host.jobs?.contains(where: { $0.documentID == job.id }) ?? false
            }
            
            print("Fetched \(self.hostJobs.count) jobs for the current recruiter")
            
            // Create job cards for host jobs
            await MainActor.run {
                self.createHostJobCards()
            }
            
        } catch {
            print("Error fetching jobs: \(error.localizedDescription)")
        }
    }
    
    func fetchCompanies() async {
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("companies").getDocuments()
            
            let allCompanies = querySnapshot.documents.compactMap { doc -> CompanyInfo? in
                return CompanyInfo.decode(data: doc.data(), id: doc.documentID)
            }
            
            await MainActor.run {
                self.companies = allCompanies
                print("Fetched \(self.companies.count) companies")
                
                // Recreate job cards with updated company info
                self.createJobCards()
            }
            
        } catch {
            print("Error fetching companies: \(error.localizedDescription)")
        }
    }
    
    func fetchHosts() {
        let db = Firestore.firestore()
        db.collection("recruiters").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting hosts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found in the recruiters collection")
                return
            }
            
            self.hosts = documents.compactMap { document in
                do {
                    let host = try document.data(as: Host.self)
                    print("Successfully decoded host with ID: \(host.id ?? "unknown")")
                    return host
                } catch {
                    print("Error decoding host document \(document.documentID): \(error.localizedDescription)")
                    return nil
                }
            }
            
            print("Fetched \(self.hosts.count) hosts")
        }
    }
    
    // MARK: - JobCards Creation and Management
    
    private func createJobCards() {
        // Create job cards from current jobs and companies
        self.jobCards = JobCards.createJobCards(from: self.jobs, companies: self.companies)
        print("Created \(self.jobCards.count) job cards")
    }
    
    private func createHostJobCards() {
        // Create job cards for host jobs
        let hostJobCards = JobCards.createJobCards(from: self.hostJobs, companies: self.companies)
        
        // You might want to store these separately or merge them
        // For now, we'll add them to the main jobCards array
        self.jobCards.append(contentsOf: hostJobCards)
        print("Created \(hostJobCards.count) host job cards")
    }
    

    // MARK: - Private Helper Methods
    
    
    
    private func hasUserApplied(user: User, to job: HostJob) -> Bool {
        let db = Firestore.firestore()
        let jobRef = db.collection("jobs").document(job.id ?? "")
        return (user.jobs_applied?.contains(jobRef) ?? false)
    }
    
    private func hasUserDeclined(user: User, to job: HostJob) -> Bool {
        let db = Firestore.firestore()
        let jobRef = db.collection("jobs").document(job.id ?? "")
        return (user.jobs_declined?.contains(jobRef) ?? false)
    }
    
    private func removeJobFromList(_ job: HostJob) {
        if let index = jobs.firstIndex(of: job) {
            jobs.remove(at: index)
        }
        
        // Also remove from job cards
        jobCards.removeAll { $0.job?.id == job.id }
    }
    
    private func removeJobCardFromList(_ jobCard: JobCards) {
        if let index = jobCards.firstIndex(of: jobCard) {
            jobCards.remove(at: index)
        }
        
        // Also remove from jobs if exists
        if let job = jobCard.job {
            removeJobFromList(job)
        }
    }
    
    // MARK: - Navigation and Utility
    
    func getNextJob(for user: User) -> HostJob? {
        currentJobIndex = 0
        while currentJobIndex < jobs.count {
            let job = jobs[currentJobIndex]
            if !hasUserApplied(user: user, to: job) && !hasUserDeclined(user: user, to: job) {
                currentJobIndex += 1
                return job
            }
            currentJobIndex += 1
        }
        currentJobIndex = 0
        return nil
    }
    
    func getNextJobCard(for user: User) -> JobCards? {
        let availableJobCards = jobCards.filter { jobCard in
            guard let job = jobCard.job else { return false }
            return !hasUserApplied(user: user, to: job) && !hasUserDeclined(user: user, to: job)
        }
        
        return availableJobCards.first
    }
    
    func getUserReference(user_id: String) -> DocumentReference {
        return Firestore.firestore().collection("jobseekers").document(user_id)
    }
    
    func getUserFromReference(reference: DocumentReference, completion: @escaping (DocumentSnapshot?, Error?) -> Void) {
        reference.getDocument(completion: completion)
    }
    
    // MARK: - Company Management
    
    func getCompanyInfo(for job: HostJob) -> CompanyInfo? {
        if let companyId = job.company_id {
            return companies.first { company in
                company.company_id?.documentID == companyId.documentID
            }
        }
        
        // Fallback to name matching
        return companies.first { company in
            company.company_name == job.company_name
        }
    }
    
    func refreshJobCards() {
        Task {
            await fetchCompanies()
            await MainActor.run {
                self.createJobCards()
            }
        }
    }
}

// MARK: - Supporting Enums

enum JobCardSortType {
    case datePosted
    case salary
    case company
    case applicantCount
}





// MARK: - JobCards Struct
struct JobCards: Identifiable, Hashable, Codable {
    
    internal init(id: String? = nil, job: HostJob? = nil, company: CompanyInfo? = nil, displayTitle: String? = nil, displayLocation: String? = nil, displayCompanyName: String? = nil, displayLogo: String? = nil, displayPay: String? = nil, displayEmploymentType: String? = nil, displayDatePosted: Date? = nil, displaySkills: [String]? = nil, applicantCount: Int? = nil) {
        self.id = id
        self.job = job
        self.company = company
        self.displayTitle = displayTitle
        self.displayLocation = displayLocation
        self.displayCompanyName = displayCompanyName
        self.displayLogo = displayLogo
        self.displayPay = displayPay
        self.displayEmploymentType = displayEmploymentType
        self.displayDatePosted = displayDatePosted
        self.displaySkills = displaySkills
    }
    
    @DocumentID var id: String?
    
    // Core data
    var job: HostJob?
    var company: CompanyInfo?
    
    // Display properties for optimized card rendering
    var displayTitle: String?
    var displayLocation: String?
    var displayCompanyName: String?
    var displayLogo: String?
    var displayPay: String?
    var displayEmploymentType: String?
    var displayDatePosted: Date?
    var displaySkills: [String]?
    var applicantCount: Int?
    
    // MARK: - Computed Propertie
    
    var timeAgo: String {
        guard let job = job, let timestamp = job.date_posted else { return "Recently posted" }
        let date = timestamp.dateValue()
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        }
        return "Just posted"
    }
    
    // MARK: - Initialization from HostJob and CompanyInfo
    static func create(from job: HostJob, company: CompanyInfo?) -> JobCards {
        let jobCard = JobCards(
            id: job.id,
            job: job,
            company: company,
            displayTitle: job.job_title,
            displayLocation: job.job_location,
            displayCompanyName: job.company_name ?? company?.company_name,
            displayLogo: company?.company_logo,
            displayPay: job.job_pay != nil ? String(job.job_pay!) : nil,
            displayEmploymentType: job.employment_type,
            displayDatePosted: job.date_posted?.dateValue(),
            displaySkills: job.job_skills,
            applicantCount: job.job_applicants?.count ?? 0
        )
        return jobCard
    }
    
    // MARK: - Equatable & Hashable
    static func == (lhs: JobCards, rhs: JobCards) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Decode from Firestore
    static func decode(data: [String : Any], id: String) -> JobCards {
        // Decode job data
        let jobData = data["job"] as? [String: Any]
        let job = jobData != nil ? HostJob.decode(data: jobData!, id: jobData!["id"] as? String ?? "") : nil
        
        // Decode company data
        let companyData = data["company"] as? [String: Any]
        let company = companyData != nil ? CompanyInfo.decode(data: companyData!, id: companyData!["id"] as? String ?? "") : nil
        
        // Decode display properties
        let displayTitle = data["displayTitle"] as? String
        let displayLocation = data["displayLocation"] as? String
        let displayCompanyName = data["displayCompanyName"] as? String
        let displayLogo = data["displayLogo"] as? String
        let displayPay = data["displayPay"] as? String
        let displayEmploymentType = data["displayEmploymentType"] as? String
        let displayDatePosted = (data["displayDatePosted"] as? Timestamp)?.dateValue()
        let displaySkills = data["displaySkills"] as? [String]
        let applicantCount = data["applicantCount"] as? Int
        
        return JobCards(
            id: id,
            job: job,
            company: company,
            displayTitle: displayTitle,
            displayLocation: displayLocation,
            displayCompanyName: displayCompanyName,
            displayLogo: displayLogo,
            displayPay: displayPay,
            displayEmploymentType: displayEmploymentType,
            displayDatePosted: displayDatePosted,
            displaySkills: displaySkills,
            applicantCount: applicantCount
        )
    }
}

// MARK: - Usage Example
extension JobCards {
    
    // MARK: - Batch Creation
    static func createJobCards(from jobs: [HostJob], companies: [CompanyInfo]) -> [JobCards] {
        var jobCards: [JobCards] = []
        
        for job in jobs {
            // Find matching company by company_id or company_name
            let matchingCompany = companies.first { company in
                if let jobCompanyId = job.company_id, let companyId = company.company_id {
                    return jobCompanyId.documentID == companyId.documentID
                }
                return job.company_name == company.company_name
            }
            
            let jobCard = JobCards.create(from: job, company: matchingCompany)
            jobCards.append(jobCard)
        }
        
        return jobCards
    }
    
    // MARK: - Filtering Methods
    func matchesSearchTerm(_ searchTerm: String) -> Bool {
        let lowercasedTerm = searchTerm.lowercased()
        
        return displayTitle?.lowercased().contains(lowercasedTerm) == true ||
               displayCompanyName?.lowercased().contains(lowercasedTerm) == true ||
               displayLocation?.lowercased().contains(lowercasedTerm) == true ||
               job?.about_the_job?.lowercased().contains(lowercasedTerm) == true ||
               displaySkills?.contains { $0.lowercased().contains(lowercasedTerm) } == true
    }
    
    func matchesEmploymentType(_ employmentType: String) -> Bool {
        return displayEmploymentType?.lowercased() == employmentType.lowercased()
    }
    
    func isWithinSalaryRange(min: Int?, max: Int?) -> Bool {
        guard let jobPay = job?.job_pay else { return min == nil && max == nil }
        
        
        return true
    }
}
