//
//  previewJobListing.swift
//  JobsMatch
//
//  Created by ivans Android on 5/9/24.
//

import SwiftUI

struct previewJobListing: View {
    @Environment(\.dismiss) var dismiss
    @State var companyName = ""
    @State var companyDescription = ""
    @State var hostDashboardReturn = false
    @ObservedObject var jobStore: jobStore
    
    var jobField: String
    var jobPosition: String
    var jobWorkType: String
    var jobCompanyName: String
    var jobLocation: String
    var jobSalary: String
    var jobRequirements: String
    var jobCompanyBio: String
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing:-50){
                    VStack(spacing:-15){
                        Text("\(jobField)")
                            .font(Font.custom("Orkney-Bold", size: 25))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        Text("\(jobCompanyName)")
                            .font(Font.custom("Orkney-Bold", size: 20))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top,5)
                        Text("\(jobLocation)")
                            .font(Font.custom("Orkney-Regular", size: 15))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                    .padding()
                    VStack{
                        //user info divider
                        dividerWithLabel(label: "Job Description")
                            .padding()
                    }
                    .padding(.top,30)
                }
                VStack{
                    VStack(spacing:-5){
                        Text("About the Position")
                            .foregroundStyle(.black)
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .padding()
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .padding(.horizontal)
                        TextField("Jobs Match", text: $companyName,axis: .vertical)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .lineLimit(10,reservesSpace: true)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    VStack(spacing:-15){
                        VStack(spacing:-25){
                            Text("Position")
                                .foregroundStyle(.black)
                                .font(Font.custom("Orkney-Bold", size: 15))
                                .padding()
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.horizontal)
                            Text("\(jobPosition)")
                                .foregroundStyle(.black)
                                .font(Font.custom("Orkney-Regular", size: 15))
                                .padding()
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.horizontal)
                        }
                        
                        VStack(spacing:-25){
                            Text("Work Type")
                                .foregroundStyle(.black)
                                .font(Font.custom("Orkney-Bold", size: 15))
                                .padding()
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.horizontal)
                            Text("\(jobWorkType)")
                                .foregroundStyle(.black)
                                .font(Font.custom("Orkney-Regular", size: 15))
                                .padding()
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.horizontal)
                        }
                        
                        VStack(spacing:-25){
                            Text("Salary")
                                .foregroundStyle(.black)
                                .font(Font.custom("Orkney-Bold", size: 15))
                                .padding()
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.horizontal)
                            Text("\(jobSalary)")
                                .foregroundStyle(.black)
                                .font(Font.custom("Orkney-Regular", size: 15))
                                .padding()
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.horizontal)
                        }
                        VStack(spacing:-25){
                            Text("Requirements")
                                .foregroundStyle(.black)
                                .font(Font.custom("Orkney-Bold", size: 15))
                                .padding()
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.horizontal)
                            VStack(spacing:-30){
                                Text("• Currently Enrolled in a 4 year Univesity")
                                    .foregroundStyle(.black)
                                    .font(Font.custom("Orkney-Regular", size: 15))
                                    .padding()
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                    .padding(.horizontal,40)
                                
                                Text("• Studying Computer Science")
                                    .foregroundStyle(.black)
                                    .font(Font.custom("Orkney-Regular", size: 15))
                                    .padding()
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                    .padding(.horizontal,40)
                                Text("• Over 3.0 GPA")
                                    .foregroundStyle(.black)
                                    .font(Font.custom("Orkney-Regular", size: 15))
                                    .padding()
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                    .padding(.horizontal,40)
                            }
                        }
                    }
                    VStack{
                        //user info divider
                        dividerWithLabel(label: "Job Description")
                            .padding()
                    }
                    VStack{
                        Text("About Us")
                            .foregroundStyle(.black)
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .padding()
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .padding(.horizontal)
                        TextField("Jobs Match",text: $companyDescription, axis: .vertical)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .lineLimit(10,reservesSpace: true)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                    }
                    Button(action: {
                        let newJobListing = jobListing(jobField: jobField, jobPosition: jobPosition, jobWorkType: jobWorkType, jobCompanyName: jobCompanyName, jobLocation: jobLocation, jobSalary: jobSalary, jobRequiremnets: jobRequirements, jobCompanyBio: jobCompanyBio)
                            jobStore.addEvent(newJobListing)
                        hostDashboardReturn.toggle()
                    }) {
                        Text("Post New Job Card | 100001")
                            .font(Font.custom("Orkney-Bold",size: 18))
                            .opacity(3)
                            .foregroundColor(.white)
                            .frame(width:300,height:40)
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding()
                        }
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Create Job Card")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .foregroundColor(skyBlueColor.skyBlue)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .scrollIndicators(.hidden)
        .fullScreenCover(isPresented: $hostDashboardReturn) {
            hostDashboard(jobStore: jobStore)
        }
    }
}

#Preview {
    let defaultJobStore = jobStore()

        // Pass default or empty values to the initializer
        return previewJobListing(
            jobStore: defaultJobStore,
            jobField: "",
            jobPosition: "",
            jobWorkType: "",
            jobCompanyName: "",
            jobLocation: "",
            jobSalary: "",
            jobRequirements: "",
            jobCompanyBio: ""
        )
}
