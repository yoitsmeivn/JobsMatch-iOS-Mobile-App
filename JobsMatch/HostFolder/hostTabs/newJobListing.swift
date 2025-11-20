//
//  newJobListing.swift
//  JobsMatch
//
//  Created by ivans Android on 4/24/24.
//

import SwiftUI

struct newJobListing: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var jobStore: jobStore
    @State var previewListing = false
    
    @State var showJobField: Bool = false
    @State var selectedjobField: String
    let jobFields = ["Software", "Engineering", "Marketing", "Business", "Biology", "Food Service"]
    
    @State var showPositions: Bool = false
    @State var selectedPosition: String
    let positions = ["Intern", "Part Time","Full Time","Other"]
    
    @State var showWorkType: Bool = false
    @State var selectedWorkType: String
    let workType = ["Remote","Hybrid","On Site"]
    
    @State var companyName = "JobsMatch"
    @State var jobLocation = ""
    
    @State var aboutPosition = ""
    
    @State var salarySelect = false
    @State var Salary = ""
    
    @State var requirements = ""
    
    @State var companyBio = ""
    
    var body: some View {
        ScrollView{
            VStack(spacing:-20){
                Text("Create Job Listing")
                    .font(Font.custom("Orkney-Bold", size: 25))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                dividerWithLabel(label: "Job Information")
                    .padding()
            }
            VStack(spacing:10){
                VStack(spacing:-15){
                    Text("Job Field")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showJobField {
                        jobPositionSelectionView
                    } else {
                        jobPositionsButton
                    }
                }
                VStack(spacing:-15){
                    Text("Company Name")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    Text("\(companyName)")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Regular", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                }
                VStack(spacing:0){
                    Text("Job Location")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    TextField("City & State",text: $jobLocation)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                }
                dividerWithLabel(label: "Job Description")
                    .padding()
                
                VStack(spacing:-10){
                    Text("About the Position")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    TextField("\(companyName)",text: $aboutPosition,axis: .vertical)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .lineLimit(10,reservesSpace: true)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                }
                VStack(spacing:-15){
                    Text("Positions")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showPositions {
                        positionSelectionView
                    } else {
                        positionsButton
                    }
                }
                VStack(spacing:-15){
                    Text("Work Type")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showWorkType {
                        workTypeSelectionView
                    } else {
                        workTypeButton
                    }
                }
                VStack(spacing:-40){
                    Text("Salary")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    HStack(spacing:-36){
                        Image(systemName:"dollarsign")
                        TextField("Salary",text: $Salary)
                            .font(Font.custom("Orkney-Regular", size: 15))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding(.horizontal,35)
                        Toggle(isOn: $salarySelect, label: {
                            HStack{
                                Text(salarySelect ? "Hourly":"Month")
                                    .foregroundStyle(.black)
                                    .font(Font.custom("Orkney-Regular", size: 15))
                                Image(systemName:"dollarsign.arrow.circlepath")
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: skyBlueColor.skyBlue))
                        .padding()
                    }
                    .padding()
                }
                VStack(spacing:-10){
                    Text("Requirements")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    TextField("Requirements",text: $requirements,axis: .vertical)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .lineLimit(10,reservesSpace: true)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                }
                dividerWithLabel(label: "About the Company")
                    .padding()
                
                VStack(spacing:-10){
                    Text("Company Bio")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    TextField("Company Bio",text: $companyBio,axis: .vertical)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .lineLimit(10,reservesSpace: true)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding(.horizontal,35)
                }
                Button(action: {
                    _ = jobListing(jobField: selectedjobField, jobPosition: selectedPosition, jobWorkType: selectedWorkType, jobCompanyName: companyName, jobLocation: jobLocation, jobSalary: Salary, jobRequiremnets: requirements, jobCompanyBio: companyBio)
                    previewListing.toggle()
                }) {
                    Text("Preview")
                        .font(Font.custom("Orkney-Bold",size: 18))
                        .opacity(3)
                        .foregroundColor(.white)
                        .frame(width:300,height:40)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding()
                    }
            }
            .scrollIndicators(.hidden)
            .fullScreenCover(isPresented: $previewListing) {
                previewJobListing(jobStore: jobStore,
                                  jobField: selectedjobField,
                                  jobPosition: selectedPosition,
                                  jobWorkType: selectedWorkType,
                                  jobCompanyName: companyName,
                                  jobLocation: jobLocation,
                                  jobSalary: Salary,
                                  jobRequirements: requirements,
                                  jobCompanyBio: companyBio)
            }
        }
    }
    private var jobPositionsButton: some View {
        Button(action: {
            showJobField.toggle()
        }) {
            Text(selectedjobField)
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(.white))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var jobPositionSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(jobFields, id: \.self) { field in
                MultipleSelectionRowJobField(field: field, isSelected: field == selectedjobField) {
                    selectedjobField = field
                    showJobField = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: jobFields)
    }
    
    private var positionsButton: some View {
        Button(action: {
            showPositions.toggle()
        }) {
            Text(selectedPosition)
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(.white))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var positionSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(positions, id: \.self) { position in
                MultipleSelectionRowPositions(position: position, isSelected: position == selectedPosition) {
                    selectedPosition = position
                    showPositions = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: jobFields)
    }
    
    private var workTypeButton: some View {
        Button(action: {
            showWorkType.toggle()
        }) {
            Text(selectedWorkType)
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(.white))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var workTypeSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(workType, id: \.self) { workType in
                MultipleSelectionRowWorkType(workType: workType, isSelected: workType == selectedWorkType) {
                    selectedWorkType = workType
                    showWorkType = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: jobFields)
    }

    
}

struct MultipleSelectionRowJobField: View {
    var field: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(field)
                .foregroundColor(Color.primary)
                .font(Font.custom("Orkney-Regular", size: 15))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 10).fill(.white))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MultipleSelectionRowPositions: View {
    var position: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(position)
                .foregroundColor(Color.primary)
                .font(Font.custom("Orkney-Regular", size: 15))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 10).fill(.white))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MultipleSelectionRowWorkType: View {
    var workType: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(workType)
                .foregroundColor(Color.primary)
                .font(Font.custom("Orkney-Regular", size: 15))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 10).fill(.white))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    newJobListing(
            jobStore: jobStore(), // Provide a jobStore instance
            selectedjobField: "Select Job Field", // Default value for job field
            selectedPosition: "Select Position", // Default value for position
            selectedWorkType: "Select Work Type" // Default value for work type
        )
}
