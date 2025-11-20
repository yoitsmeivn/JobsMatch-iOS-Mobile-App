
import SwiftUI
import FirebaseStorage
import AppTrackingTransparency
import AdSupport

struct userResume: View {
    @State private var navigateToNextView = false
    @Environment(\.dismiss) private var dismiss
    
    @State var showEducationOptions: Bool = false
    @State var selectedEducation: String?
    

    let educationOptions = ["None","High School", "Associate's Degree", "Bachelor's Degree", "Master's Degree", "Doctoral Degree"]
    
    @State private var age = ""
    @State private var school_name = ""
    @State private var major = ""
    @State private var end_date = ""
    @State private var start_date = ""
    @State private var minor = ""
    
    
    @State var showExperienceOptions: Bool = false
    @State var selectedExperience: String?
    
    @State private var company_name = ""
    @State private var description = ""
    @State private var employment_type = ""
    @State private var experience_end_date = ""
    @State private var experience_start_date = ""
    @State private var location = ""
    
    @State var showDisability: Bool = false
    @State var selectedDisability: String?
    let disabilityOptions = ["I have a disability as considered by the American Disability Act","I do not have a disability as considered by teh American Disability Act"]
    
    @State var showMilitaryStatus: Bool = false
    @State var selectedMilitaryStatus: String?
    let militaryStatusOptions = ["Active Duty","Retired Veteran","No, I have not served in the military"]
    
    @State var showWorkEligibility: Bool = false
    @State var selectedEligibility: String?

    let eligibilityOptions = ["Citizen", "Permanent Resident","Work Visa","Other"]
    
    @State var showPositions: Bool = false
    @State var selectedPositions: String?

    let positionOptions = ["Intern", "Part Time","Full Time","Other"]
    
    var isFormValid: Bool {
            !school_name.isEmpty &&
            selectedEducation != nil &&
            !major.isEmpty &&
            !end_date.isEmpty &&
            !start_date.isEmpty &&
            selectedMilitaryStatus != nil &&
            selectedDisability != nil &&
            selectedPositions != nil &&
            selectedEligibility != nil &&
            resume != nil
        }
    
    @State private var resume: URL?
    @State private var presentImporter = false
    @State private var fileName = ""
    
    var body: some View {
        ZStack {
            // Assuming a light theme for the app; adjust colors accordingly
            skyBlueColor.skyBlue
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing() // Dismiss keyboard when tapping outside
                }
            
            VStack(spacing: 20) {
                headerView
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName:"chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color.black)
                            .padding()
                    }
                    Spacer()
                }
                instructionView
                ScrollView{
                    VStack(spacing: -25){
                        Text("Highest or Current Education")
                            .foregroundStyle(.black)
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .padding()
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    }
                    
                    TextField("Enter your Institution Name",text: $school_name)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10.0)
                        .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                        .padding(.horizontal, 15)
                    
                    if school_name != "" {
                        Text("Type of Degree Earned")
                            .foregroundStyle(.black)
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .padding()
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                        if showEducationOptions {
                            educationSelectionView
                        } else {
                            educationButton
                        }
                        
                        Text("Your Major(If none, enter None)")
                            .foregroundStyle(.black)
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .padding()
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                        TextField("Enter your major",text: $major)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10.0)
                            .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                            .padding(.horizontal, 15)
                        
                        TextField("Enter your minor(If None, enter None)",text: $minor)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10.0)
                            .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                            .padding(.horizontal, 15)
                        
                        Text("Dates")
                            .foregroundStyle(.black)
                            .font(Font.custom("Orkney-Bold", size: 15))
                            .padding()
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                        TextField("Enter your Start Date",text: $start_date)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10.0)
                            .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                            .padding(.horizontal, 15)
                        
                        TextField("Enter your End Date",text: $end_date)
                            .font(Font.custom("Orkney-Regular", size: 12))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10.0)
                            .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                            .padding(.horizontal, 15)
                    }
                    experienceSection
                    
                    Text("Your Age")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    TextField("Enter your Age",text: $age)
                        .font(Font.custom("Orkney-Regular", size: 12))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10.0)
                        .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                        .padding(.horizontal, 15)
                    
                    Text("Your Desired Position")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showPositions {
                        positionSelectionView
                    } else {
                        positionsButton
                    }
                    
                    Text("Your Work Eligibility(U.S. Specific)")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showWorkEligibility {
                        eligibilitySelectionView
                    } else {
                        eligibilityButton
                    }
                    
                    Text("Do you identify as a person with a disability?(U.S. Specific)")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showDisability {
                        disabilitesSelectionView
                    } else {
                        disabilitesButton
                    }
                    
                    Text("Do you have prior or current military service?(U.S. Specific)")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if showMilitaryStatus {
                        militarySelectionView
                    } else {
                        militaryButton
                    }
                    
                    
                    Text("Upload Resume (PDF Only)")
                        .foregroundStyle(.black)
                        .font(Font.custom("Orkney-Bold", size: 15))
                        .padding()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    uploadResumeButton
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    Button(action: {
                        saveUserData4()
                        navigateToNextView = true
                    }) {
                        Text("Continue")
                            .font(Font.custom("Orkney-Bold", size: 18))
                            .opacity(3)
                            .foregroundColor(skyBlueColor.skyBlue)
                            .frame(width: 300, height: 40)
                            .background(Color.black.opacity(isFormValid ? 1.0 : 0.5))
                            .cornerRadius(10)
                            .padding()
                    }
                    .disabled(!isFormValid)
                    .navigationDestination(isPresented: $navigateToNextView) {
                        userPassword()
                    }
                
                }
            }
            .padding()
            .onAppear{
                TrackingPermissionManager.showPrivacyExplanationDialog()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
        HStack{
            Image("JobsMatchBluebackground")
                .resizable()
                .frame(width:200,height:55)
                .padding(.bottom)
            Spacer()
        }
    }
    
    private var instructionView: some View {
        VStack(spacing: 20) {
            Text("You're almost there!")
                .foregroundStyle(.black)
                .font(Font.custom("Orkney-Bold", size: 18))
            Text("Tell us about yourself")
                .foregroundStyle(.black)
                .font(Font.custom("Orkney-Bold", size: 18))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var educationButton: some View {
        Button(action: {
            showEducationOptions.toggle()
        }) {
            Text(selectedEducation ?? "Select your highest education")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var educationSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(educationOptions, id: \.self) { education in
                MultipleSelectionRowEducation(education: education, isSelected: education == selectedEducation) {
                    selectedEducation = education
                    showEducationOptions = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: showEducationOptions)
    }
    
    
    private var experienceSection: some View {
            VStack {
                Text("Your Most Recent Work Experience")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 15))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Enter the Company Name", text: $company_name)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                    .padding(.horizontal, 15)

                if company_name != "" {
                    experienceDetails
                }
            }
        }
    private var experienceDetails: some View {
            VStack {
                Text("Your Title")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 15))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter your role or job title", text: $description)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                    .padding(.horizontal, 15)
                Text("Your Employement Type")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 15))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Full-time, Part-time, Intern,etc.", text: $employment_type)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                    .padding(.horizontal, 15)
                Text("Location")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 15))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter location", text: $location)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                    .padding(.horizontal, 15)
                Text("Dates")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 15))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter your start date", text: $experience_start_date)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                    .padding(.horizontal, 15)

                TextField("Enter your end date", text: $experience_end_date)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                    .padding(.horizontal, 15)
            }
        }

    
    private var eligibilityButton: some View {
        Button(action: {
            showWorkEligibility.toggle()
        }) {
            Text(selectedEligibility ?? "Select your status")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var eligibilitySelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(eligibilityOptions, id: \.self) { eligibility in
                MultipleSelectionRowWorkEligibility(eligibility: eligibility, isSelected: eligibility == selectedEligibility) {
                    selectedEligibility = eligibility
                    showWorkEligibility = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var positionsButton: some View {
        Button(action: {
            showPositions.toggle()
        }) {
            Text(selectedPositions ?? "Select your desired role")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var positionSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(positionOptions, id: \.self) { position in
                MultipleSelectionRowPosition(position: position, isSelected: position == selectedPositions) {
                    selectedPositions = position
                    showPositions = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var disabilitesButton: some View {
        Button(action: {
            showDisability.toggle()
        }) {
            Text(selectedDisability ?? "Select your disability status")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var disabilitesSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(disabilityOptions, id: \.self) { disability in
                MultipleSelectionRowDisability(disability: disability, isSelected: disability == selectedDisability) {
                    selectedDisability = disability
                    showDisability = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var militaryButton: some View {
        Button(action: {
            showMilitaryStatus.toggle()
        }) {
            Text(selectedMilitaryStatus ?? "Select your Military status")
                .foregroundColor(Color.black)
                .font(Font.custom("Orkney-Regular", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(skyBlueColor.skyBlue))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var militarySelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(militaryStatusOptions, id: \.self) { military in
                MultipleSelectionRowMilitary(military: military, isSelected: military == selectedMilitaryStatus) {
                    selectedMilitaryStatus = military
                    showMilitaryStatus = false
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var uploadResumeButton: some View {
        Button(action: {
            presentImporter.toggle()
        }) {
            HStack {
                Image(systemName: resume != nil ? "checkmark" : "paperclip")
                Text(resume != nil ? fileName : "Attach Resume")
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundColor(.black)
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .fileImporter(
            isPresented: $presentImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let file = files.first {
                    fileName = file.lastPathComponent
                    resume = file
                    print("File name: \(fileName)")
                    print("File path: \(file.path)")
                    print("Full file URL: \(file)")
                    guard file.startAccessingSecurityScopedResource() else {
                        print("Failed to access security-scoped resource")
                        return
                    }
                    
                    // Ensure we release the security-scoped resource when done
                    defer {
                        file.stopAccessingSecurityScopedResource()
                    }
                    
                    // Get the documents directory
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsDirectory.appendingPathComponent(file.lastPathComponent)
                                    
                    
                    do {
                        // Remove any existing file
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        
                        // Copy the file to documents directory
                        try FileManager.default.copyItem(at: file, to: destinationURL)
                        
                        // Store the file information
                        fileName = file.lastPathComponent
                        resume = destinationURL
                        
                        // Save the local path
                        UserDefaults.standard.set(destinationURL.path, forKey: "resumePath")
                        
                        print("File successfully copied to: \(destinationURL.path)")
                        
                        // Create and save bookmark data
                        let bookmarkData = try destinationURL.bookmarkData(
                            options: .minimalBookmark,
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil
                        )
                        UserDefaults.standard.set(bookmarkData, forKey: "resumeBookmark")
                        
                    } catch {
                        print("Error handling file: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
    
    
    func saveUserData4() {
        var educationArray: [[String: String]] = []
        if !school_name.isEmpty {
            let educationDict: [String: String] = [
                "school_name": school_name,
                "degree": selectedEducation ?? "",
                "major": major,
                "end_date": end_date,
                "start_date": start_date,
                "minor" : minor
            ]
            educationArray.append(educationDict)
        }
        var experienceArray: [[String: String]] = []
        let experienceDict: [String: String] = [
            "company_name": company_name,
            "description": description,
            "employment_type": employment_type,
            "location": location,
            "start_date": experience_start_date,
            "end_date": experience_end_date
        ]
        experienceArray.append(experienceDict)
        print(experienceArray)
        
        UserDefaults.standard.set(educationArray, forKey: "educationArray")
        UserDefaults.standard.set(experienceArray, forKey: "experienceArray")
        UserDefaults.standard.set(age, forKey: "age")
        UserDefaults.standard.set(selectedEligibility, forKey: "selectedEligibility")
        UserDefaults.standard.set(selectedPositions, forKey: "selectedPositions")
        UserDefaults.standard.set(selectedDisability, forKey: "selectedDisability")
        UserDefaults.standard.set(selectedMilitaryStatus, forKey: "selectedMilitaryStatus")
        
        if let resume = resume {
            do {
                let bookmarkData = try resume.bookmarkData(
                    options: .minimalBookmark,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                UserDefaults.standard.set(bookmarkData, forKey: "resume")
            } catch {
                print("Failed to create bookmark: \(error)")
            }
        }
    }
}

struct MultipleSelectionRowEducation: View {
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
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
struct MultipleSelectionRowAge: View {
    var age: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(age)
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
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MultipleSelectionRowWorkEligibility: View {
    var eligibility: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(eligibility)
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
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MultipleSelectionRowPosition: View {
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
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


struct MultipleSelectionRowDisability: View {
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
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MultipleSelectionRowMilitary: View {
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
        .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
        .onTapGesture(perform: action)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


struct uploadResume4: View {
    @State private var presentImporter = false
    @State private var fileName = ""
    @State private var fileURL: URL?

    var body: some View {
        Button(action: {
            presentImporter.toggle()
        }) {
            HStack {
                Image(systemName: fileURL != nil ? "checkmark" : "paperclip")
                Text(fileURL != nil ? fileName : "Attach Resume")
                    .font(Font.custom("Orkney-Regular", size: 15))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundColor(.black)
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 10).fill(skyBlueColor.skyBlue))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .fileImporter(
            isPresented: $presentImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let file = files.first {
                    fileName = file.lastPathComponent
                    fileURL = file
                    // Store the file URL in UserDefaults
                    if let urlString = file.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        UserDataManager.saveResume(urlString)
                    }
                    print(fileName)
                    print(fileURL ?? "")
                }
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
}

struct userResume_Previews: PreviewProvider {
    static var previews: some View {
        userResume()
    }
}




class TrackingPermissionManager {
    static func requestTrackingPermission() {
        // Check iOS version supports tracking transparency
        guard #available(iOS 14.0, *) else { return }
        
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // User authorized tracking
                print("Tracking permission granted")
                
                // Optional: Get advertising identifier if allowed
                let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                
            case .denied:
                print("Tracking permission denied")
                
            case .restricted, .notDetermined:
                print("Tracking permission restricted or not determined")
                
            @unknown default:
                break
            }
        }
    }
    
    // Custom privacy explanation dialog
    static func showPrivacyExplanationDialog() {
        let alert = UIAlertController(
            title: "Data Collection",
            message: "We collect user data to improve app functionality, personalize your experience, and provide essential services. Your data is securely stored and never sold to third parties.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Understand", style: .default, handler: { _ in
            requestTrackingPermission()
        }))
        
        // Present this alert before requesting tracking permission
        // You'll need to call this from your view controller
        // viewController.present(alert, animated: true)
    }
}
