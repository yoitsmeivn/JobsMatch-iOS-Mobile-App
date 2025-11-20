import SwiftUI
import Firebase

// MARK: - TopArcShape
/// This shape draws a simple arc across the top portion of the screen.
struct TopArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start at top-left, extending beyond visible area
        path.move(to: CGPoint(x: 0, y: -100))
        // Line across to top-right, extending beyond visible area
        path.addLine(to: CGPoint(x: rect.width, y: -100))
        // Line straight down a bit
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.5))
        // Quad curve back to left
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height * 0.5),
            control: CGPoint(x: rect.width / 2, y: rect.height * 1.15)
        )
        // Close subpath
        path.closeSubpath()
        return path
    }
}

struct myProfile: View {
    @StateObject var userManager = UserManager.shared
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State var showMyProfileEditView = false

    var body: some View {
        ZStack(alignment: .top) {
            // 1) Blue background that extends beyond safe area
            Color(skyBlueColor.skyBlue)
                .ignoresSafeArea(.all)

            // 2) The arc shape - now covers more area
            TopArcShape()
                .fill(Color(skyBlueColor.skyBlue))
                .frame(height: UIScreen.main.bounds.height * 0.35)
                .offset(x: 0, y: -80)

            // 3) Main content goes on top of the arc
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 0) {
                        // Top section with back button and resume circle
                        ZStack {
                            // Back button
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
                            .padding(.top, -80)
                            
                            // Profile "picture" that is actually the resume
                            ZStack {
                                // White circle
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 120, height: 120)
                                    .shadow(radius: 8)
                                
                                // Resume background image
                                Image("ProfileResume")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                                    .opacity(0.3)
                                
                                // Resume icon overlay
                                VStack(spacing: 6) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color.black.opacity(0.8))
                                    
                                    if let resume = authService.currentUser?.resume,
                                       !resume.isEmpty {
                                        Text(getFileName(from: resume))
                                            .font(Font.custom("Orkney-Regular", size: 10))
                                            .foregroundColor(Color.black)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    } else {
                                        Text("Missing Resume Path")
                                            .font(Font.custom("Orkney-Regular", size: 9))
                                            .foregroundColor(Color.black)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding(8)
                            }
                            .padding(.top, -30)
                        }
                        .frame(height: 200)

                        // Main content area with white background
                        VStack(spacing: 0) {
                            // Title
                            Text("Your Profile")
                                .font(Font.custom("helvetica-bold", size: 28))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.top, 30)
                                .padding(.bottom, 20)

                            // Personal Information Section
                            VStack(spacing: 16) {
                                sectionHeader("Personal Information")
                                
                                // Name and Email in clean cards
                                profileCard(title: "Full Name", value: authService.currentUser?.full_name ?? "")
                                profileCard(title: "Email Address", value: authService.currentUser?.email ?? "")
                                
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 30)

                            // Bio Section
                            VStack(spacing: 16) {
                                sectionHeader("About Me")
                                
                                if let bio = authService.currentUser?.user_bio, !bio.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(bio)
                                            .font(Font.custom("Orkney-Regular", size: 16))
                                            .foregroundColor(.black)
                                            .lineLimit(nil)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                                } else {
                                    profileCard(title: "Bio", value: "")
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 30)

                            // Skills Section
                            VStack(spacing: 16) {
                                sectionHeader("Skills")
                                
                                if let skills = authService.currentUser?.skills, !skills.isEmpty {
                                    skillsGridView(skills: skills)
                                } else {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.8)) {
                                            proxy.scrollTo("editButton", anchor: .bottom)
                                        }
                                    }) {
                                        Text("Add Skills")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 24)
                                            .background(
                                                Capsule()
                                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                                    .background(Capsule().fill(Color.white))
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 30)

                            // Links Section
                            VStack(spacing: 16) {
                                sectionHeader("Links")
                                
                                if let links = authService.currentUser?.links, !links.isEmpty {
                                    ForEach(Array(links.keys.sorted()), id: \.self) { title in
                                        if let url = links[title] {
                                            linkCard(title: title, url: url)
                                        }
                                    }
                                } else {
                                    profileCard(title: "Links", value: "")
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 30)

                            // Education Section
                            VStack(spacing: 16) {
                                sectionHeader("Education")
                                
                                if let educationList = authService.currentUser?.education, !educationList.isEmpty {
                                    ForEach(educationList, id: \.self) { education in
                                        educationCard(education: education)
                                    }
                                } else {
                                    profileCard(title: "Education", value: "")
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 30)

                            // Experience Section
                            VStack(spacing: 16) {
                                sectionHeader("Work Experience")
                                
                                if let experienceList = authService.currentUser?.experience, !experienceList.isEmpty {
                                    ForEach(experienceList, id: \.self) { experience in
                                        experienceCard(experience: experience)
                                    }
                                } else {
                                    profileCard(title: "Experience", value: "")
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 30)

                            // US Specific Information
                            VStack(spacing: 16) {
                                sectionHeader("US Specific Information")
                                
                                profileCard(title: "Work Eligibility", value: authService.currentUser?.work_eligibility ?? "Not specified")
                                profileCard(title: "Disability Status", value: authService.currentUser?.disability_status ?? "Not specified")
                                profileCard(title: "Military Status", value: authService.currentUser?.military_status ?? "Not specified")
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)

                            // Edit button
                            Button(action: { showMyProfileEditView.toggle() }) {
                                Text("Edit Profile")
                                    .font(Font.custom("helvetica-bold", size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(skyBlueColor.skyBlue)
                                    .cornerRadius(20)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                            .id("editButton")
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .offset(y: -20)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            if authService.currentUser == nil {
                print("DEBUG: No current user found on view appear")
            } else {
                print("DEBUG: Current user found on view appear: \(authService.currentUser?.email ?? "unknown")")
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showMyProfileEditView) {
            myProfileEdit()
                .environmentObject(authService)
                .environmentObject(UserManager())
        }
    }

    // MARK: - Helper Views
    
    @ViewBuilder
    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(Font.custom("helvetica-bold", size: 18))
                .foregroundColor(.black)
            Spacer()
        }
    }
    
    @ViewBuilder
    func profileCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.custom("helvetica-bold", size: 14))
                .foregroundColor(.gray)
            Text(value.isEmpty ? "" : value)
                .font(Font.custom("Orkney-Regular", size: 16))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func linkCard(title: String, url: String) -> some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(Font.custom("helvetica-bold", size: 14))
                    .foregroundColor(.gray)
                Text(url)
                    .font(Font.custom("Orkney-Regular", size: 16))
                    .foregroundColor(.blue)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    func skillsGridView(skills: [String]) -> some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            FlexibleView(
                data: skills,
                spacing: 8,
                alignment: .leading
            ) { skill in
                Text(skill)
                    .font(Font.custom("Orkney-Regular", size: 12))
                    .foregroundColor(.white)
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
    }
    
    @ViewBuilder
    func educationCard(education: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(education["school_name"] ?? "Unknown School")
                .font(Font.custom("helvetica-bold", size: 16))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 6) {
                if let degree = education["degree"], !degree.isEmpty {
                    Text("Degree: \(degree)")
                        .font(Font.custom("Orkney-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                if let major = education["major"], !major.isEmpty {
                    Text("Major: \(major)")
                        .font(Font.custom("Orkney-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                if let minor = education["minor"], !minor.isEmpty, minor != "N/A" {
                    Text("Minor: \(minor)")
                        .font(Font.custom("Orkney-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    if let startDate = education["start_date"], !startDate.isEmpty {
                        Text(startDate)
                            .font(Font.custom("Orkney-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    if let endDate = education["end_date"], !endDate.isEmpty {
                        Text("- \(endDate)")
                            .font(Font.custom("Orkney-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func experienceCard(experience: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(experience["company_name"] ?? "Unknown Company")
                .font(Font.custom("helvetica-bold", size: 16))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 6) {
                if let description = experience["description"], !description.isEmpty {
                    Text(description)
                        .font(Font.custom("Orkney-Regular", size: 14))
                        .foregroundColor(.black)
                        .lineLimit(3)
                }
                if let employmentType = experience["employment_type"], !employmentType.isEmpty {
                    Text("Type: \(employmentType)")
                        .font(Font.custom("Orkney-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                if let location = experience["location"], !location.isEmpty {
                    Text("Location: \(location)")
                        .font(Font.custom("Orkney-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    if let startDate = experience["start_date"], !startDate.isEmpty {
                        Text(startDate)
                            .font(Font.custom("Orkney-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    if let endDate = experience["end_date"], !endDate.isEmpty {
                        Text("- \(endDate)")
                            .font(Font.custom("Orkney-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    // Helper for extracting file name from a resume URL
    func getFileName(from url: String) -> String {
        return URL(string: url)?.lastPathComponent ?? "Unknown file"
    }
}

struct myProfile_Previews: PreviewProvider {
    static var previews: some View {
        myProfile()
            .environmentObject(UserManager())
            .environmentObject(AuthService())
    }
}
