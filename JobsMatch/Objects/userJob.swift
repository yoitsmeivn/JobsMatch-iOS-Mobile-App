//
//  userJob.swift
//  JobsMatch
//
//  Created by ivans Android on 4/8/24.
//
import UIKit
import Foundation

struct Job: Identifiable, Hashable, Equatable {
    var id = UUID()
    var job: String
    var companyName: String
    var location: String
    var jobType: String
    var employmentType: String
    var jobImage: UIImage?
    var dates: String?
    var jobBio: String?
    var companyBio: String?
    var requirements: Array<String>?
    var benefits: Array<String>?
    var pay: String?
    var usersApplied: [UUID]
}

/*
func userToJob(user: User, job: inout Job) {
    if !job.usersApplied.contains(currentUser.id) {
        job.usersApplied.append(currentUser.id)
    }
}
*/



let mockJobs = [
    Job(job: "Software", companyName: "JobsMatch", location: "San Francisco,CA", jobType: "Full-Time",employmentType: "Remote", jobImage: UIImage(named:"JobsMatchLogo"),usersApplied: []),
    Job(job: "Engineering", companyName: "JobsMatch", location: "Tucson,AZ", jobType: "Full-Time",employmentType: "On Site", jobImage: UIImage(named:"JobsMatchLogo"),usersApplied: []),
    Job(job: "Biology", companyName: "JobsMatch", location: "Palo Alto,CA", jobType: "Intern",employmentType: "Hybrid", jobImage: UIImage(named:"JobsMatchLogo"),dates: "6/1/24-7/1/24",usersApplied: [])
]

