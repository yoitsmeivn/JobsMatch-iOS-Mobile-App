//
//  FirestoreService.swift
//  JobsMatch
//
//  Created by ivans Android on 1/10/25.
//

import Foundation
import FirebaseFirestore

enum FirestoreService {
    
    enum Collection: String {
        case jobSeekers = "jobseekers"
        case jobs = "jobs"
    }
    
    static func collectionRef(for collection: Collection) -> CollectionReference {
        Firestore.firestore().collection(collection.rawValue)
    }
}
