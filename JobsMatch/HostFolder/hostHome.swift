//
//  hostHome.swift
//  JobsMatch
//
//  Created by ivans Android on 4/22/24.
//

import SwiftUI

struct hostHome: View {
    @EnvironmentObject var authServiceHost: AuthServiceHost
    @EnvironmentObject var authService: AuthService
    var body: some View {
        TabView{
            hostDashboard(jobStore: jobStore())
                .tabItem{
                    Image(systemName:"pencil.and.list.clipboard")
                }
            
            fypPage(authService:authService)
                .environmentObject(authServiceHost)
                .tabItem{
                    Image(systemName:"clipboard")
                }
            hostMessages()
                .environmentObject(authServiceHost)
                .tabItem{
                    Image(systemName:"message")
                }
        }
        .accentColor(skyBlueColor.skyBlue)
        .navigationBarBackButtonHidden(true)
    }
}

struct hostHome_Previews: PreviewProvider {
    static var previews: some View {
        hostHome()
            .environmentObject(AuthServiceHost())
    }
}
