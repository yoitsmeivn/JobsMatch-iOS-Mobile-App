//
//  hostDashboard.swift
//  JobsMatch
//
//  Created by ivans Android on 4/24/24.
//

import SwiftUI


struct hostDashboard: View {
    @ObservedObject var jobStore: jobStore
    @EnvironmentObject var authServiceHost: AuthServiceHost
    @State var isScroll = false
    @State var jobListing = false
    var body: some View {
        NavigationStack {
            VStack(spacing:-50) {
                // Blue bar
                RoundedRectangle(cornerRadius: 4.0)
                    .foregroundColor(skyBlueColor.skyBlue)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-732)
                    .blur(radius: 1)
                    .overlay(
                        HStack{
                            Image("JobsMatchBluebackground")
                                .resizable()
                                .frame(width:200,height:55)
                                .padding(.top,28)
                            Spacer()
                        }
                            .padding(.horizontal)
                    )
                ZStack(alignment: .top) {
                    ScrollView {
                        VStack(alignment: .leading){
                            HStack{
                                NavigationLink{
                                    hostProfile()
                                }label: {
                                    Text("Profile")
                                        .foregroundColor(.black)
                                        .font(Font.custom("Orkney-Bold",size:20))
                                        .fontWeight(.heavy)
                                }
                                .padding(.horizontal)
                                .padding(.top,150)
                                Spacer()
                            }
                            
                            NavigationLink{
                                activityPageMain(authService: AuthService.shared) // Pass the correct AuthService instance
                                        .environmentObject(authServiceHost)
                            }label: {
                                Text("Activity")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Orkney-Bold",size:20))
                            }
                            .padding(.horizontal)
                            .padding(.top,55)
                            
                            NavigationLink{
                                hostProfile()
                            }label: {
                                Text("History")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Orkney-Bold",size:20))
                            }
                            .padding(.horizontal)
                            .padding(.top,55)
                            
                            NavigationLink{
                                hostProfile()
                            }label: {
                                Text("Calendar")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Orkney-Bold",size:20))
                            }
                            .padding(.horizontal)
                            .padding(.top,55)
                            
                            NavigationLink{
                                hostProfile()
                            }label: {
                                Text("Interviews")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Orkney-Bold",size:20))
                            }
                            .padding(.horizontal)
                            .padding(.top,55)
                            
                            
                            NavigationLink{
                                hostSettings()
                            }label: {
                                Text("Settings")
                                    .foregroundColor(.black)
                                    .font(Font.custom("Orkney-Bold",size:20))
                            }
                            .padding(.horizontal)
                            .padding(.top,55)
                        }
                    }
                }
                VStack{
                    HStack{
                        Spacer()
                        Button(action: {
                            jobListing.toggle()
                        }) {
                            Circle()
                                .frame(width:70,height:70)
                                .foregroundStyle(skyBlueColor.skyBlue)
                                .overlay(
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width:30,height:30)
                                        .foregroundStyle(.white)
                                )
                        }
                        .padding()
                        .sheet(isPresented: $jobListing){
                            ScrollView{
                                newJobListing(
                                        jobStore: jobStore, // Provide a jobStore instance
                                        selectedjobField: "Select Job Field", // Default value for job field
                                        selectedPosition: "Select Position", // Default value for position
                                        selectedWorkType: "Select Work Type" // Default value for work type
                                    )
                            }
                        }
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

// Preview provider for SwiftUI previews in Xcode
struct hostDashboard_Previews: PreviewProvider {
    static var previews: some View {
        hostDashboard(jobStore: jobStore())
            .environmentObject(AuthServiceHost())
    }
}
