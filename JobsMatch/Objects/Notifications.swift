//
//  Notifications.swift
//  JobsMatch
//
//  Created by ivans Android on 6/21/24.
//

import SwiftUI
import UserNotifications

func requestNotificationAuthorization() { //notification function for granting permisison
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Notifications Enabled")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}
