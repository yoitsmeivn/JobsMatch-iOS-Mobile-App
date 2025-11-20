//
//  hostInfo.swift
//  JobsMatch
//
//  Created by ivans Android on 5/22/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore



struct Host: Identifiable, Codable {
    @DocumentID var id: String?
    var company_id: String?
    var company_name: String?
    var employee_email: String?
    var employee_first_name: String?
    var employee_last_name: String?
    var role_flag: Int?
    var jobs: [DocumentReference]?
    var superior: DocumentReference?

    enum CodingKeys: String, CodingKey {
        case id, employee_first_name, employee_last_name, company_id, employee_email, role_flag, jobs, superior
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        employee_first_name = try container.decode(String.self, forKey: .employee_first_name)
        employee_last_name = try container.decode(String.self, forKey: .employee_last_name)
        company_id = try container.decode(String.self, forKey: .company_id)
        employee_email = try container.decode(String.self, forKey: .employee_email)
        jobs = try container.decodeIfPresent([DocumentReference].self, forKey: .jobs)
        superior = try container.decodeIfPresent(DocumentReference.self, forKey: .superior)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(employee_first_name, forKey: .employee_first_name)
        try container.encode(employee_last_name, forKey: .employee_last_name)
        try container.encode(company_id, forKey: .company_id)
        try container.encode(employee_email, forKey: .employee_email)
        try container.encodeIfPresent(jobs, forKey: .jobs)
        try container.encodeIfPresent(superior, forKey: .superior)
    }
}


