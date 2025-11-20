//
//  myProfileEdit.swift
//  JobsMatch
//
//  Created by ivans Android on 4/4/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct myProfileEdit: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var userManager = UserManager.shared
    @EnvironmentObject var authService: AuthService
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Existing state variables
    @State var emailEdit = ""
    @State var fullNameEdit = ""
    @State var bioEdit = ""
    @State var highestEducationEdit = ""
    @State var positionEdit = ""
    @State var interestsEdit: [String] = []
    @State var workEligibilityEdit = ""
    @State var disabilityStatusEdit = ""
    @State var militaryStatusEdit = ""
    @State var schoolEdit = ""
    @State var fileNameEdit = ""
    @State var ageEdit = ""
    @State var majorEdit = ""
    @State var minorEdit = ""
    @State var startYearEdit = ""
    @State var endYearEdit = ""
    @State var isLoading = false
    
    @State var currentResumeURL: String? = ""
    @State private var presentImporter = false
    @State private var resumeURL: URL?
    @State private var newResumeFileName = ""
    
    @State var linkURLTemp = ""
    @State var skillsEdit: [String] = []
    @State var linksEdit: [[String: String]] = []
    @State var showSkillsSearch = false
    @State var skillSearchText = ""
    @State var availableSkills: [String] = [
        "Swift", "SwiftUI", "iOS Development", "UIKit", "Core Data", "Firebase",
        "JavaScript", "Python", "React", "Node.js", "Java", "Kotlin", "Flutter",
        "Machine Learning", "AI", "Data Science", "SQL", "MongoDB", "AWS", "Azure",
        "Git", "Docker", "Kubernetes", "DevOps", "Agile", "Scrum", "Project Management",
        "UI/UX Design", "Figma", "Adobe Creative Suite", "Marketing", "Sales",
        "Customer Service", "Leadership", "Communication", "Problem Solving"
    ]
    @State var filteredSkills: [String] = []
    @State var selectedLinkType = "GitHub"

    let linkTypes = ["GitHub", "LinkedIn", "Portfolio", "Website", "Twitter"]

    @State var companyEdit = ""
    
    @State var roleEdit = ""
    @State var descriptionEdit = ""
    @State var locationEdit = ""
    @State var startYearExperienceEdit = ""
    @State var endYearExperienceEdit = ""
    
    
    @State var educationList: [[String: String]] = []
    @State var experienceList: [[String: String]] = []

    

    // New state variables for selection views
    @State var showEducationOptions: Bool = false
    @State var showWorkEligibility: Bool = false
    @State var showPositions: Bool = false
    @State var showDisability: Bool = false
    @State var showMilitaryStatus: Bool = false

    let educationOptions = ["None", "High School", "Associate's Degree", "Bachelor's Degree", "Master's Degree", "Doctoral Degree"]
    let eligibilityOptions = ["Citizen", "Permanent Resident","Work Visa","Other"]
    let positionOptions = ["Intern", "Part Time", "Full Time", "Other"]
    let militaryStatusOptions = ["Active Duty","Retired Veteran","No, I have not served in the military"]
    let disabilityOptions = ["I have a disability as considered by the American Disability Act","I do not have a disability as considered by teh American Disability Act"]
    
    
    private func filterSkills() {
        if skillSearchText.isEmpty {
            filteredSkills = []
        } else {
            filteredSkills = availableSkills.filter { skill in
                skill.lowercased().contains(skillSearchText.lowercased()) &&
                !skillsEdit.contains(skill)
            }
        }
    }

    private func iconForLinkType(_ type: String) -> String {
        switch type {
        case "GitHub": return "link.circle"
        case "LinkedIn": return "person.circle"
        case "Portfolio": return "briefcase.circle"
        case "Website": return "globe.circle"
        case "Twitter": return "at.circle"
        case "Behance": return "paintbrush.circle"
        case "Dribbble": return "circle.circle"
        default: return "link.circle"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: -5) {
                    // User info divider
                    dividerWithLabel(label: "Personal Information")
                        .padding()
                    
                    // First Name and Last Name
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Full Name")
                                .font(Font.custom("Orkney-Bold", size: 15))
                            TextField("Full Name", text: $fullNameEdit)
                                .font(Font.custom("Orkney-Regular", size: 12))
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(6.0)
                        }
                    }
                    .padding()
                    
                    Text("Bio")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    TextField("Tell us about yourself...", text: $bioEdit, axis: .vertical)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .lineLimit(4...8)
                        .padding()
                    
                    Text("Your Skills")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                    // Skills Search Bar
                    HStack {
                        TextField("Search skills...", text: $skillSearchText)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .onChange(of: skillSearchText) { newValue in
                                filterSkills()
                            }
                        
                        Button("Add Custom") {
                            if !skillSearchText.isEmpty && !skillsEdit.contains(skillSearchText) {
                                skillsEdit.append(skillSearchText)
                                skillSearchText = ""
                            }
                        }
                        .font(Font.custom("Orkney-Bold", size: 12))
                        .foregroundColor(skyBlueColor.skyBlue)
                    }
                    .padding()

                    if !skillsEdit.isEmpty {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            FlexibleView(
                                data: skillsEdit,
                                spacing: 8,
                                alignment: .leading
                            ) { skill in
                                HStack(spacing: 6) {
                                    Text(skill)
                                        .font(Font.custom("Orkney-Regular", size: 12))
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        skillsEdit.removeAll { $0 == skill }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                            .font(.system(size: 14))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.pink.opacity(0.7),
                                                    Color.purple.opacity(0.6)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .shadow(color: Color.pink.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    // Skills Suggestions
                    if !skillSearchText.isEmpty {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(filteredSkills.prefix(10), id: \.self) { skill in
                                    Button(action: {
                                        if !skillsEdit.contains(skill) {
                                            skillsEdit.append(skill)
                                            skillSearchText = ""
                                        }
                                    }) {
                                        HStack {
                                            Text(skill)
                                                .font(Font.custom("Orkney-Regular", size: 14))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(skyBlueColor.skyBlue)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(maxHeight: 200)
                    }
                    
                    Text("Your Links")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                    // Add Link Section
                    VStack {
                        HStack {
                            // Link Type Picker
                            Menu {
                                ForEach(linkTypes, id: \.self) { linkType in
                                    Button(linkType) {
                                        selectedLinkType = linkType
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedLinkType)
                                        .font(Font.custom("Orkney-Regular", size: 12))
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(6.0)
                            }
                            .foregroundColor(.primary)
                            
                            TextField("Enter URL", text: $linkURLTemp)
                                .font(Font.custom("Orkney-Regular", size: 12))
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(6.0)
                            
                            Button("Add") {
                                if !linkURLTemp.isEmpty {
                                    let newLink = ["type": selectedLinkType, "url": linkURLTemp]
                                    linksEdit.append(newLink)
                                    linkURLTemp = ""
                                }
                            }
                            .font(Font.custom("Orkney-Bold", size: 12))
                            .foregroundColor(skyBlueColor.skyBlue)
                        }
                        .padding()
                        
                        // Display existing links
                        ForEach(linksEdit.indices, id: \.self) { index in
                            HStack {
                                Image(systemName: iconForLinkType(linksEdit[index]["type"] ?? ""))
                                    .foregroundColor(skyBlueColor.skyBlue)
                                
                                VStack(alignment: .leading) {
                                    Text(linksEdit[index]["type"] ?? "")
                                        .font(Font.custom("Orkney-Bold", size: 12))
                                    Text(linksEdit[index]["url"] ?? "")
                                        .font(Font.custom("Orkney-Regular", size: 10))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    linksEdit.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }


                    // Education
                    dividerWithLabel(label: "Education")
                        .padding()
                    
                    Text("Your Education")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    if showEducationOptions {
                        educationSelectionView
                    } else {
                        educationButton
                    }

                    // School
                    if highestEducationEdit != "" {
                        Text("Academic Institution")
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        TextField("Enter your Institution", text: $schoolEdit)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding()

                        Text("Your Major")
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        TextField("Enter your major", text: $majorEdit)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding()
                        
                        Text("Your Minor")
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        TextField("Enter your minor", text: $minorEdit)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding()

                        Text("Your School Dates")
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        TextField("Enter your start date", text: $startYearEdit)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding()
                        TextField("Enter your expected graduation date", text: $endYearEdit)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(6.0)
                            .padding()
                    }
                    
                    
                    dividerWithLabel(label: "Experience")
                        .padding()
                    
                    if showPositions {
                        positionSelectionView
                    }
                    
                    // Company
                    Text("Company Name")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    TextField("Enter the company name", text: $companyEdit)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding()
                    
                    
                    Text("Description")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    TextField("Description", text: $descriptionEdit)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding()

                    // Role
                    Text("Your Employment Type")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    TextField("Enter your role", text: $roleEdit)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding()
                    
                    Text("Location")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    TextField("Location", text: $locationEdit)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding()
                    // Dates for experience
                    Text("Your Experience Dates")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                    TextField("Enter your start date", text: $startYearExperienceEdit)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding()
                    TextField("Enter your end date", text: $endYearExperienceEdit)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(6.0)
                        .padding()
                    
                    
                    dividerWithLabel(label: "U.S. Specific")
                        .padding()
                    // Work Eligibility
                    
                    Text("Your Work Eligibility (U.S. Specific)")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    if showWorkEligibility {
                        eligibilitySelectionView
                    } else {
                        eligibilityButton
                    }
                    //disability status
                    Text("Your Disability Status (U.S. Specific)")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    if showDisability {
                        disabilitesSelectionView
                    } else {
                        disabilitesButton
                    }
                    
                    //military status
                    Text("Your Military Status (U.S. Specific)")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    if showMilitaryStatus {
                        militarySelectionView
                    } else {
                        militaryButton
                    }
                    
                    
                    dividerWithLabel(label: "Resume")
                        .padding()
                    // Resume
                    Text("Resume")
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    resumeUploadSection
                       .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .foregroundColor(skyBlueColor.skyBlue)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .foregroundColor(skyBlueColor.skyBlue)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadUserDataEdit()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Update Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var educationButton: some View {
        Button(action: {
            showEducationOptions.toggle()
        }) {
            Text(highestEducationEdit.isEmpty ? "Select your highest education" : highestEducationEdit)
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray).opacity(0.2))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding()
    }
    
    private var educationSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(educationOptions, id: \.self) { education in
                MultipleSelectionRowEducationEdit(education: education, isSelected: education == highestEducationEdit) {
                    highestEducationEdit = education
                    showEducationOptions = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: showEducationOptions)
        .padding()
    }
    
    private var positionsButton: some View {
            Button(action: {
                showPositions.toggle()
            }) {
                Text(roleEdit.isEmpty ? "Select your desired role" : roleEdit)
                    .foregroundColor(Color.black)
                    .font(Font.custom("Orkney-Regular", size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray).opacity(0.2))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
    
    private var positionSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(positionOptions, id: \.self) { position in
                MultipleSelectionRowPositionEdit(position: position, isSelected: position == roleEdit) {
                    roleEdit = position
                    showPositions = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: showPositions)
        .padding()
    }
    
    
    private var eligibilityButton: some View {
        Button(action: {
            showWorkEligibility.toggle()
        }) {
            Text(workEligibilityEdit.isEmpty ? "Select your status" : workEligibilityEdit)
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray).opacity(0.2))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding()
    }
    
    private var eligibilitySelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(eligibilityOptions, id: \.self) { eligibility in
                MultipleSelectionRowWorkEligibilityEdit(eligibilty: eligibility, isSelected: eligibility == workEligibilityEdit) {
                    workEligibilityEdit = eligibility
                    showWorkEligibility = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding()
    }
    
    private var disabilitesButton: some View {
        Button(action: {
            showDisability.toggle()
        }) {
            Text(disabilityStatusEdit.isEmpty ? "Select your status" : disabilityStatusEdit)
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray).opacity(0.2))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding()
    }
    
    private var disabilitesSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(disabilityOptions, id: \.self) { disability in
                MultipleSelectionRowDisabilityEdit(disability: disability, isSelected: disability == disabilityStatusEdit) {
                    disabilityStatusEdit = disability
                    showDisability = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding()
    }
    
    private var militaryButton: some View {
        Button(action: {
            showMilitaryStatus.toggle()
        }) {
            Text(militaryStatusEdit.isEmpty ? "Select your status" : militaryStatusEdit)
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray).opacity(0.2))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding()
    }
    
    private var militarySelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(militaryStatusOptions, id: \.self) { military in
                MultipleSelectionRowMilitaryEdit(military: military, isSelected: military == militaryStatusEdit) {
                    militaryStatusEdit = military
                    showMilitaryStatus = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding()
    }
    
    
    
    private var resumeUploadSection: some View {
        VStack(alignment: .leading) {
            if let resumeURLString = currentResumeURL, !resumeURLString.isEmpty {
                // If resume exists, display its filename with option to view or upload a new one
                if let resumeFileName = URL(string: resumeURLString)?.lastPathComponent {
                    HStack {
                        Text("\(resumeFileName)")
                            .font(Font.custom("Orkney-Regular", size: 15))
                        Spacer()
                        HStack(spacing: -20) {
                            Spacer()
                            Button(isLoading ? "" : "Upload New Resume") {
                                presentImporter = true
                                isLoading = true
                            }
                            .font(Font.custom("Orkney-Bold", size: 13))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.black)
                            .contentShape(Rectangle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            if isLoading {
                                HStack{
                                    CustomLoadingView(color: skyBlueColor.skyBlue)
                                        .frame(width: 25, height: 25)
                                    Spacer()
                                }
                            }
                            Image(systemName: "paperclip")
                                .padding()
                            
                        }
                    }
                }
            } else {
                Button(action: {
                    presentImporter.toggle()
                }) {
                    Text(isLoading ? "" : "Upload Resume")
                        .font(Font.custom("Orkney-Regular", size: 15))
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray).opacity(0.2))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    if isLoading {
                        CustomLoadingView(color: skyBlueColor.skyBlue)
                            .frame(width: 25, height: 25)
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $presentImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let file):
                if let url = file.first {
                    guard url.pathExtension.lowercased() == "pdf" else {
                        alertMessage = "Please upload a PDF file"
                        showingAlert = true
                        return
                    }
                    
                    guard url.startAccessingSecurityScopedResource() else {
                        alertMessage = "Failed to access the selected file"
                        showingAlert = true
                        isLoading = false
                        return
                    }
                    
                    // Ensure we release the security-scoped resource when done
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    
                    // Read the data from the original file
                    guard let fileData = try? Data(contentsOf: url) else {
                        alertMessage = "Failed to read file data"
                        showingAlert = true
                        isLoading = false
                        return
                    }
                    
                    if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                        
                        do {
                            // Remove existing file if present
                            if FileManager.default.fileExists(atPath: destinationURL.path) {
                                try FileManager.default.removeItem(at: destinationURL)
                            }
                            
                            // Write the new file
                            try fileData.write(to: destinationURL)
                            
                            // Update UI
                            newResumeFileName = url.lastPathComponent
                            resumeURL = destinationURL
                            
                            // Save path and start upload
                            UserDefaults.standard.set(destinationURL.path, forKey: "resume")
                            uploadResumeToAll(url: destinationURL)
                            
                        } catch {
                            alertMessage = "Error saving file: \(error.localizedDescription)"
                            showingAlert = true
                            isLoading = false
                        }
                    }
                }
            case .failure(let error):
                alertMessage = "Error selecting file: \(error.localizedDescription)"
                showingAlert = true
            }
        }
        .padding(.horizontal)
    }

    // Function to save file locally
    private func saveFileLocally(url: URL) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                return nil
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            // Read data from original file
            guard let fileData = try? Data(contentsOf: url) else {
                return nil
            }
            
            // Remove existing file if present
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Write the new file
            try fileData.write(to: destinationURL)
            return destinationURL
        } catch {
            print("Error saving file locally: \(error)")
            return nil
        }
    }

    // Main upload function that handles both Firebase and FastAPI uploads
    private func uploadResumeToAll(url: URL) {
        isLoading = true
        guard let userId = authService.currentUser?.id else {
            alertMessage = "User ID not found"
            showingAlert = true
            return
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
                alertMessage = "Resume file not found"
                showingAlert = true
                isLoading = false
                return
            }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("resumes/\(userId)/\(url.lastPathComponent)")
        
        // Upload to Firebase
        storageRef.putFile(from: url, metadata: nil) { metadata, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Error uploading to Firebase: \(error.localizedDescription)"
                    self.showingAlert = true
                    isLoading = false
                }
                return
            }
            
            // Get Firebase download URL
            storageRef.downloadURL { downloadURL, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.alertMessage = "Error getting download URL: \(error.localizedDescription)"
                        self.showingAlert = true
                        isLoading = false
                    }
                    return
                }
                
                guard let downloadURL = downloadURL?.absoluteString else {
                    DispatchQueue.main.async {
                        self.alertMessage = "Download URL is nil"
                        self.showingAlert = true
                        isLoading = false
                    }
                    return
                }
                
                // Upload to FastAPI
                // 5. Upload to FastAPI Docker
                self.uploadToFastAPI(fileURL: url, userId: userId, firebaseURL: downloadURL) { result in
                    switch result {
                    case .success:
                        print("Successfully uploaded to FastAPI")
                        self.saveResumeURLToFirestore(url: downloadURL)
                        isLoading = false
                        
                    case .failure(let error):
                        print("Failed to upload to FastAPI: \(error.localizedDescription)")
                        // Handle specific error cases if needed
                        if let jwtError = error as? JWTManager.JWTError {
                            switch jwtError {
                            case .expired:
                                print("JWT Token expired - user needs to re-authenticate")
                            case .invalidToken:
                                print("Invalid JWT Token")
                            case .encodingFailed:
                                print("JWT encoding failed")
                            }
                        }
                    }
                }
            }
        }
    }

    // FastAPI upload function
    func uploadToFastAPI(fileURL: URL, userId: String, firebaseURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let jwtToken = JWTManager.shared.getToken() else {
            // Token is missing or invalid, generate new one
            JWTManager.shared.generateJWTToken(userId: userId, email: authService.currentUser?.email ?? "") { result in
                switch result {
                case .success(let newToken):
                    JWTManager.shared.saveToken(newToken)
                    // Retry the upload with new token
                    self.uploadToFastAPI(fileURL: fileURL, userId: userId, firebaseURL: firebaseURL, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        
        guard let apiURL = URL(string: "") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        guard FileManager.default.fileExists(atPath: fileURL.path),
              let resumeData = try? Data(contentsOf: fileURL) else {
            completion(.failure(URLError(.fileDoesNotExist)))
            return
        }
        
        if let token = JWTManager.shared.getToken() {
            print("\n=== Token Debug Info ===")
            JWTManager.shared.debugToken(token)
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        
        // Ensure proper Bearer token format
        let authHeader = "Bearer \(jwtToken)".trimmingCharacters(in: .whitespaces)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let boundary = userId // Use a unique boundary
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add resume file to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"resume\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
        body.append(resumeData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body

        // Add debug logging
        #if DEBUG
        print("Request Body Structure:")
        if let bodyString = String(data: body, encoding: .utf8) {
            print(bodyString)
        }
        #endif
         
        // Add metadata
        let metadata = [
            "user_id": userId,
            "firebase_url": firebaseURL
        ]
        
        for (key, value) in metadata {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        

        // Debug logging
        #if DEBUG
        print("🔐 Request Details:")
        print("URL:", request.url?.absoluteString ?? "")
        print("Headers:", request.allHTTPHeaderFields ?? [:])
        print("User ID:", userId)
        #endif
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            // Enhanced error handling
            if httpResponse.statusCode == 403 {
                #if DEBUG
                print("⛔️ Authentication Failed (403):")
                print("Response Headers:", httpResponse.allHeaderFields)
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Error Response:", errorResponse)
                }
                #endif
                
                // Check if token is expired and try to refresh
                if JWTManager.shared.isTokenExpired(jwtToken) {
                    completion(.failure(JWTManager.JWTError.expired))
                    return
                }
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    completion(.failure(NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse])))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }

    // Update Firestore with resume URL
    private func saveResumeURLToFirestore(url: String) {
        guard var currentUser = authService.currentUser else { return }
        currentUser.resume = url
        
        Task {
            do {
                try await authService.updateUser(currentUser)
                await MainActor.run {
                    self.currentResumeURL = url
                    self.alertMessage = "Resume uploaded successfully"
                    self.showingAlert = true
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = "Failed to update resume in database: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    
    private func loadUserDataEdit() {
        if let currentUser = authService.currentUser {
            emailEdit = currentUser.email ?? ""
            fullNameEdit = currentUser.full_name ?? ""
            bioEdit = currentUser.user_bio ?? ""
            skillsEdit = currentUser.skills ?? []
            linksEdit = currentUser.links != nil ? [currentUser.links!] : []
            //gender = currentUser.gender ?? ""
            //pronouns = currentUser.pronouns ?? ""
            highestEducationEdit = currentUser.education?.first?["degree"] as? String ?? ""
            //positionEdit = currentUser.desired_position ?? ""
            //interestsEdit = currentUser.job_filters ?? []
            workEligibilityEdit = currentUser.work_eligibility ?? ""
            disabilityStatusEdit = currentUser.disability_status ?? ""
            militaryStatusEdit = currentUser.military_status ?? ""
            schoolEdit = currentUser.education?.first?["school_name"] as? String ?? ""
            majorEdit = currentUser.education?.first?["major"] as? String ?? ""
            minorEdit = currentUser.education?.first?["minor"] as? String ?? ""
            startYearEdit = currentUser.education?.first?["start_date"] as? String ?? ""
            endYearEdit = currentUser.education?.first?["end_date"] as? String ?? ""
            
            currentResumeURL = currentUser.resume
            
            companyEdit = currentUser.experience?.first?["company_name"] as? String ?? ""
            roleEdit = currentUser.experience?.first?["employment_type"] as? String ?? ""
            descriptionEdit = currentUser.experience?.first?["description"] as? String ?? ""
            locationEdit = currentUser.experience?.first?["location"] as? String ?? ""
            startYearExperienceEdit = currentUser.experience?.first?["start_date"] as? String ?? ""
            endYearExperienceEdit = currentUser.experience?.first?["end_date"] as? String ?? ""
            // Note: Resume filename might need to be handled differently depending on how it's stored
        }else{
            print("no user got in here")
        }
    }
    
    
    private func saveChanges() {
        guard var updatedUser = authService.currentUser else {
            alertMessage = "No user data available"
            showingAlert = true
            return
        }
        
        // Update user properties
        updatedUser.full_name = fullNameEdit
        updatedUser.user_bio = bioEdit
        //updatedUser.gender = gender
        //updatedUser.pronouns = pronouns
        updatedUser.work_eligibility = workEligibilityEdit
        updatedUser.military_status = militaryStatusEdit
        updatedUser.disability_status = disabilityStatusEdit
        
        // Update education
        if !schoolEdit.isEmpty {
            updatedUser.education = [
                [
                    "school_name": schoolEdit,
                    "degree": highestEducationEdit,
                    "major": majorEdit,
                    "minor": minorEdit,
                    "start_date": startYearEdit,
                    "end_date": endYearEdit
                ]
            ]
        } else {
            updatedUser.education = []
        }
            
            updatedUser.experience = [
                [
                    "company_name": companyEdit,
                    "description": descriptionEdit,
                    "employment_type": roleEdit,
                    "location": locationEdit,
                    "start_date": startYearExperienceEdit,
                    "end_date": endYearExperienceEdit
                ]
            ]
                
                // Call updateUser method
                Task {
                    do {
                        try await authService.updateUser(updatedUser)
                        await MainActor.run {
                            alertMessage = "Profile updated successfully"
                            showingAlert = true
                            dismiss()
                        }
                    } catch {
                        await MainActor.run {
                            alertMessage = "Failed to update profile: \(error.localizedDescription)"
                            showingAlert = true
                        }
                    }
                }
            }
        }

        struct MultipleSelectionRowEducationEdit: View {
            var education: String
            var isSelected: Bool
            var action: () -> Void

            var body: some View {
                HStack {
                    Text(education)
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
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray).opacity(0.2))
                .onTapGesture(perform: action)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }

        struct MultipleSelectionRowWorkEligibilityEdit: View {
            var eligibilty: String
            var isSelected: Bool
            var action: () -> Void

            var body: some View {
                HStack {
                    Text(eligibilty)
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
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray).opacity(0.2))
                .onTapGesture(perform: action)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }

        struct MultipleSelectionRowPositionEdit: View {
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
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray).opacity(0.2))
                .onTapGesture(perform: action)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        struct MultipleSelectionRowDisabilityEdit: View {
            var disability: String
            var isSelected: Bool
            var action: () -> Void

            var body: some View {
                HStack {
                    Text(disability)
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
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray).opacity(0.2))
                .onTapGesture(perform: action)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }

        struct MultipleSelectionRowMilitaryEdit: View {
            var military: String
            var isSelected: Bool
            var action: () -> Void

            var body: some View {
                HStack {
                    Text(military)
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
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray).opacity(0.2))
                .onTapGesture(perform: action)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }

#Preview {
    myProfileEdit()
        .environmentObject(AuthService())
        .environmentObject(UserManager())
}





struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0

    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .center, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }

            FlexibleViewLayout(
                data: data,
                spacing: spacing,
                availableWidth: availableWidth,
                content: content
            )
        }
    }
}

struct FlexibleViewLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let availableWidth: CGFloat
    let content: (Data.Element) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowData in
                HStack(spacing: spacing) {
                    ForEach(rowData, id: \.self) { item in
                        content(item)
                    }
                    Spacer()
                }
            }
        }
    }

    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = []
        var currentRow: [Data.Element] = []
        var currentRowWidth: CGFloat = 0

        for item in data {
            let itemWidth = estimateWidth(for: item)
            
            if currentRowWidth + itemWidth + spacing <= availableWidth || currentRow.isEmpty {
                currentRow.append(item)
                currentRowWidth += itemWidth + (currentRow.count > 1 ? spacing : 0)
            } else {
                rows.append(currentRow)
                currentRow = [item]
                currentRowWidth = itemWidth
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    func estimateWidth(for item: Data.Element) -> CGFloat {
        let text = String(describing: item)
        let font = UIFont(name: "Orkney-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width + 24 + 6 + 14 + 24 // text + horizontal padding + spacing + xmark + extra padding
    }
}

// MARK: - Size Reader Helper
extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
