//dashboard.swift
//ivan severinov
//5/15/2024


import SwiftUI

// Define common spacing constants for consistency
fileprivate let standardPadding: CGFloat = 20
fileprivate let itemSpacing: CGFloat = 16

struct scrollPreKey: PreferenceKey { // Placeholder for scroll detection
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct Dashboard: View {
    @State private var isScroll = false
    @State private var animateCircle = false // Changed to only animate circle
    @State private var showCareerInsights = false // Add state for sheet presentation
    @Binding var currentTab: TabItem

    
    // Use StateObject for objects owned by this view
    // Use ObservedObject for objects passed into this view that it doesn't own
    // Use EnvironmentObject for objects provided higher up in the hierarchy
    @StateObject var userManager = UserManager.shared // Assuming UserManager is a shared singleton
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var authService: AuthService

    // Helper function to get first name
    private var firstName: String {
        guard let fullName = authService.currentUser?.full_name else { return "User" }
        return fullName.components(separatedBy: " ").first ?? "User"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.white.edgesIgnoringSafeArea(.all) // Clean white background

                ScrollView {
                    // GeometryReader for scroll detection (alternative to preference key if needed, but pref key is fine)
                    GeometryReader { geometry in
                        Color.clear.preference(key: scrollPreKey.self, value: geometry.frame(in: .named("Scroll")).minY)
                    }
                    .frame(height: 0) // Doesn't take space

                    Spacer(minLength: 55) // Initial spacing from top (adjust if header height changes)

                    VStack(alignment: .leading, spacing: 24) { // Increased spacing between major sections
                        // --- Header Section ---
                        HStack(alignment: .center) { // Center align items vertically
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Hey \(firstName),") // Use firstName instead of full name
                                    .foregroundStyle(.black)
                                    .font(Font.custom("helvetica-bold", size: 30))

                                Text("Welcome back")
                                    .foregroundStyle(Color.gray)
                                    .font(Font.custom("helvetica", size: 16))
                            }

                            Spacer()

                            Button(action: {
                                // Show CareerInsights as a sheet instead of switching tabs
                                showCareerInsights = true
                            }) {
                                MinimalistAnalyticsCircle(
                                    jobsApplied: authService.currentUser?.jobs_applied?.count ?? 0,
                                    jobsRejected: authService.currentUser?.jobs_declined?.count ?? 0,
                                    animateCircle: animateCircle // Pass animation state
                                )
                                .frame(width: 90, height: 90) // Slightly smaller circle for balance
                            }
                            .buttonStyle(CareerInsightsButtonStyle())
                        }
                        .padding(.horizontal, standardPadding)
                        .padding(.top, standardPadding / 2) // Reduced top padding inside scroll

                        // --- Dashboard Items Section ---
                        VStack(alignment: .leading, spacing: itemSpacing) { // Use consistent itemSpacing
                            // --- Navigation Links ---
                            // Using the refined Navigation components below
                            NavigationLink {
                                // Pass existing environment objects if needed, don't create new ones here
                                // The destination view should declare @EnvironmentObject if it needs them
                                myProfile()
                            } label: {
                                NavigationSquare( // Replaced NavigationSquare2
                                    title: "Resume",
                                    description: "View and edit your JobsMatch Resume",
                                    systemImage: "person.circle"
                                )
                            }

                            HStack(spacing: itemSpacing) {
                                NavigationLink {
                                    myJobs()
                                } label: {
                                    NavigationSmallSquare(
                                        title: "Applications",
                                        description: "View Your Applications",
                                        systemImage: "list.bullet.clipboard"
                                    )
                                }

                                NavigationLink {
                                    myHistory()
                                } label: {
                                    NavigationSmallSquare(
                                        title: "History",
                                        description: "View Job History",
                                        systemImage: "clock.arrow.circlepath"
                                    )
                                }
                            }

                            NavigationLink {
                                myCalendar()
                            } label: {
                                NavigationRectangle(
                                    title: "Calendar",
                                    description: "Manage your schedule",
                                    systemImage: "calendar"
                                )
                            }

                            NavigationLink {
                                mySettings()
                            } label: {
                                NavigationSquare( // Use consistent component
                                    title: "Settings",
                                    description: "Account settings & support",
                                    systemImage: "gear"
                                )
                            }
                        }
                        .padding(.horizontal, standardPadding) // Apply horizontal padding to the section

                    } // End Main Content VStack
                    .padding(.bottom, standardPadding) // Add padding at the bottom of the scroll content

                } // End ScrollView
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "Scroll")
                .onPreferenceChange(scrollPreKey.self, perform: { value in
                    withAnimation(.easeOut(duration: 0.2)) { // Smoother animation
                        // Adjust threshold as needed, checks if scrolled past initial position
                        isScroll = value < -standardPadding
                    }
                })

                // --- Minimalist Scrolling Header ---
                if isScroll {
                    VStack(spacing: 0) { // Remove spacing inside header itself
                        HStack {
                            Text("JobsMatch")
                                .font(Font.custom("helvetica-bold", size: 18))
                                .foregroundColor(.black)

                            Spacer()

                            // Maybe use the actual user avatar if available?
                            Image(systemName: "person.circle.fill") // Slightly bolder icon
                                .font(.system(size: 22)) // Consistent size
                                .foregroundColor(.gray) // Subtle color
                        }
                        .padding(.horizontal, standardPadding) // Match content padding
                        .frame(height: 55) // Define standard header height

                        Divider() // Subtle separator line
                            // .background(Color.gray.opacity(0.2)) // Optional color for divider
                    }
                    .frame(maxWidth: .infinity) // Ensure it spans the width
                    .background(.ultraThinMaterial) // Use blur effect for modern look
                    .edgesIgnoringSafeArea(.top) // Extend background to top edge
                    .transition(.opacity.combined(with: .move(edge: .top))) // Smoother transition
                    .zIndex(1) // Ensure header stays on top
                }
            } // End ZStack
            .navigationBarHidden(true) // Keep hiding the default nav bar
            .onAppear {
                // Only animate the circle on appear
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    animateCircle = true
                }
            }
            .sheet(isPresented: $showCareerInsights) {
                // Present CareerInsights as a sheet
                CareerInsightsView(currentTab: $currentTab)
            }
        } // End NavigationStack
    }
}

// Custom button style for Career Insights circle
struct CareerInsightsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Minimalist Analytics Circle with Gradient

struct MinimalistAnalyticsCircle: View {
    let jobsApplied: Int
    let jobsRejected: Int
    let animateCircle: Bool // Add animation parameter

    private var total: Int { jobsApplied + jobsRejected }
    private var appliedPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(jobsApplied) / Double(total)
    }
    private var isEmpty: Bool { total == 0 }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background circle with more subtle gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.35, green: 0.25, blue: 0.80), // Softer deep blue
                                Color(red: 0.50, green: 0.35, blue: 0.85) // Muted blue-purple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    .shadow(color: Color(red: 0.35, green: 0.25, blue: 0.80).opacity(0.15), radius: 12, x: 5, y: 5)
                    .opacity(animateCircle ? 1 : 0) // Apply fade-in animation
                    .scaleEffect(animateCircle ? 1 : 0.8) // Apply scale animation

                // Content overlay - just the symbol and data
                VStack(spacing: 2) {
                    if isEmpty {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                        
                    }
                }
                .opacity(animateCircle ? 1 : 0) // Apply fade-in to content
                .scaleEffect(animateCircle ? 1 : 0.8) // Apply scale to content
            }
            
            // Career Insights text below the circle
            Text("Career Insights")
                .font(Font.custom("helvetica-bold", size: 11))
                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.80).opacity(0.7))
                .opacity(animateCircle ? 1 : 0) // Apply fade-in to text
                .offset(y: animateCircle ? 0 : 10) // Slight upward animation
        }
        .animation(.easeOut(duration: 0.8), value: animateCircle) // Apply animation to entire view
    }
}

// MARK: - Updated Navigation Components

// Base style for navigation items
struct NavigationCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20) // Softer corners
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2) // Subtler shadow
            )
    }
}

// --- Full Width Style ---
struct NavigationSquare: View {
    let title: String
    let description: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 15) { // Consistent spacing
            Image(systemName: systemImage)
                .font(.system(size: 20)) // Slightly smaller icon font
                .foregroundColor(skyBlueColor.skyBlue)
                .frame(width: 44, height: 44) // Slightly larger icon background
                .background(
                    RoundedRectangle(cornerRadius: 12) // Consistent corner radius
                        .fill(skyBlueColor.skyBlue.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font.custom("helvetica-bold", size: 17)) // Adjusted size
                    .foregroundColor(.black)

                Text(description)
                    .font(Font.custom("helvetica", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading) // Add this line
                    .fixedSize(horizontal: false, vertical: true)// Allow text wrapping
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold)) // Slightly bolder chevron
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(.horizontal, standardPadding)
        .frame(height: 90) // Reduced height slightly
        .modifier(NavigationCellStyle())
    }
}

// --- Half Width Style ---
// Fixed NavigationSmallSquare with proper leading alignment
struct NavigationSmallSquare: View {
    let title: String
    let description: String
    let systemImage: String

    var body: some View {
        HStack { // Use HStack instead of VStack for better control
            VStack(alignment: .leading, spacing: 12) {
                HStack { // Wrap icon in HStack to control alignment
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                        .foregroundColor(skyBlueColor.skyBlue)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(skyBlueColor.skyBlue.opacity(0.1))
                        )
                    Spacer() // Push icon to leading edge
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack { // Wrap title in HStack
                        Text(title)
                            .font(Font.custom("helvetica-bold", size: 16))
                            .foregroundColor(.black)
                        Spacer() // Push title to leading edge
                    }
                    
                    HStack { // Wrap description in HStack
                        Text(description)
                            .font(Font.custom("helvetica", size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer() // Push description to leading edge
                    }
                }
                Spacer() // Push content to top
            }
            Spacer() // This shouldn't be needed but ensures leading alignment
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading) // Add alignment here
        .modifier(NavigationCellStyle())
    }
}

// --- Full Width, Compact Style ---
struct NavigationRectangle: View {
    let title: String
    let description: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(skyBlueColor.skyBlue)
                .frame(width: 40, height: 40) // Consistent icon size
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(skyBlueColor.skyBlue.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font.custom("helvetica-bold", size: 16)) // Adjusted size
                    .foregroundColor(.black)

                Text(description)
                    .font(Font.custom("helvetica", size: 13)) // Adjusted size
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(.horizontal, standardPadding)
        .frame(height: 75) // Keep original height
        .modifier(NavigationCellStyle())
    }
}


// MARK: - Preview Provider

struct Dashboard_Previews: PreviewProvider {
    // Create instances *once* for the preview environment
    static var sharedAuthService = AuthService()
    static var sharedUserManager = UserManager.shared
    static var sharedViewModel = ViewModel()

    static var previews: some View {
        Dashboard(currentTab: .constant(.dashboard), viewModel: sharedViewModel)
            .environmentObject(sharedUserManager)
            .environmentObject(sharedAuthService) // Provide objects to the environment
    }
}
