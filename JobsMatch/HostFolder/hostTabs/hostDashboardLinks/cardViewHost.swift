//
//  cardView.swift
//  JobsMatch
//
//  Created by ivans Android on 3/25/24.
//
/*
import SwiftUI
import FirebaseFirestore

struct cardViewHost: View {
    var job: HostJob
    @EnvironmentObject var jobManager: JobManager
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack() {
                HStack {
                    Spacer()
                    Text(job.job_req_id ?? "")
                        .font(.custom("Orkney-Light", size: 20))
                        .fontWeight(.heavy)
                }
                .padding()
                
                Spacer()
                ZStack {
                    Image("JobsMatchLogo")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(.top, 100)
                }
                
                Spacer()
                .padding()
                
                HStack {
                    Text(job.job_title ?? "")
                        .font(.custom("Orkney-Light", size: 20))
                        .fontWeight(.heavy)
                    Spacer()
                    Text(job.job_location ?? "")
                        .font(.custom("Orkney-Light", size: 20))
                }
                .padding()
                
                HStack {
                    Text(job.company_name ?? "")
                        .font(.custom("Orkney-Light", size: 20))
                        .fontWeight(.heavy)
                    Spacer()
                    Text(job.employment_type ?? "")
                        .font(.custom("Orkney-Light", size: 20))
                }
                .padding()
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(.white).stroke(Color.gray, lineWidth: 1))
            .foregroundStyle(.black)
            .padding()
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 10
    }
    
    private var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 1.45
    }
}

struct cardViewHost_Previews: PreviewProvider {
   
    static var previews: some View {
        @EnvironmentObject var authService: AuthService
        let sampleJob = HostJob(
            id: "sample-id",
            job_req_id: "REQ001",
            job_title: "Software Developer",
            company_name: "Tech Corp",
            job_location: "San Francisco, CA",
            employment_type: "Full-Time",
            job_image: "https://example.com/job-image.jpg"
        )
        
        return cardViewHost(job: sampleJob)
            .environmentObject(JobManager(authService: authService))
    }
}

*/
