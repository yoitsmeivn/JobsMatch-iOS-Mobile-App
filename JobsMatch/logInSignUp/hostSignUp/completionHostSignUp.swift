//
//  completionHostSignUp.swift
//  JobsMatch
//
//  Created by ivans Android on 4/22/24.
//

import SwiftUI


struct completionHostSignUp: View {
    @State var showSlideToUnlockHostView = false
    var body: some View {
        if showSlideToUnlockHostView{
            hostHome()
        }else{
            slideToUnlockHostView(showSlideToUnlockHostView: $showSlideToUnlockHostView)
        }
    }
}
#Preview {
    completionHostSignUp()
}
