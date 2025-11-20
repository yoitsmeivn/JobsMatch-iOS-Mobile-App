//
//  Home.swift
//  JobsMatch
//
//  Created by ivans on 3/24/24.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var userManager: UserManager
    @State var showOnboarding = false
    @StateObject var viewModel = AuthService()
    @State private var currentTab: TabItem = .dashboard
    @State private var currentOnboardingStep = 1
    @State private var unreadMessagesCount: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            buildTabView()
            InteractiveTabBar(currentTab: $currentTab)
        }
        .overlay(buildOnboardingOverlay())
        .onAppear {
            let defaults = UserDefaults.standard
            showOnboarding = defaults.bool(forKey: "userWasOnboarded") == true // acc true
        }
        .accentColor(skyBlueColor.skyBlue)
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func buildTabView() -> some View {
        TabView(selection: $currentTab) {
            Dashboard(currentTab: $currentTab, viewModel: ViewModel())
                .tag(TabItem.dashboard)
                .toolbar(.hidden)
            
            fypPage(authService:AuthService())
                .tag(TabItem.fypPage)
                .toolbar(.hidden)
                
            
            userMessages()
                .tag(TabItem.messages)
                .toolbar(.hidden)
        }
    }
    
    @ViewBuilder
    private func buildOnboardingOverlay() -> some View {
        Group {
            if !showOnboarding {
                switch currentOnboardingStep {
                case 1:
                    // Step 1: Dashboard Introduction
                    Introduction(
                        page: "1/4",
                        title: "Welcome to JobsMatch!",
                        description: "Finding Jobs and Internships is Now Easier with JobsMatch",
                        description2: "Monitor your applications and edit your profile on your Dashboard",
                        buttonText: "Next",
                        showOnboarding: $showOnboarding,
                        nextStep: nextOnboardingStep,
                        backStep: backOnboardingStep
                    )
                case 2:
                    // Step 2: FYP Page Introduction (redirects to the FYP page tab)
                    Introduction(
                        page: "2/4",
                        title: "Swipe to Apply",
                        description: "Swipe to find your Dream Job tailored specifically to your needs",
                        description2: "Swipe Right to Apply, Swipe Left to Decline, and Tap on the Card Learn more about the Job on the FYP Page",
                        buttonText: "Next",
                        showOnboarding: $showOnboarding,
                        nextStep: nextOnboardingStep,
                        backStep: backOnboardingStep,
                        showBackButton: true,
                        isSecondStep: true
                    )
                    .onAppear { currentTab = .dashboard }
                case 3:
                    Introduction(
                        page: "3/4",
                        title: "Stay Connected",
                        description: "Check your messages for updates on your applications",
                        description2: "Communicate directly with recruiters through our secure messaging system",
                        buttonText: "Next",
                        showOnboarding: $showOnboarding,
                        nextStep: nextOnboardingStep,
                        backStep: backOnboardingStep,
                        showBackButton: true,
                        isSecondStep: false
                    )
                    .onAppear { currentTab = .fypPage }
                    
                case 4:
                    Introduction(
                        page: "4/4",
                        title: "You're All Set!",
                        description: "Find your next Job and Internship with JobsMatch",
                        description2: "Remember to keep your profile updated for better matches",
                        buttonText: "Get Started",
                        showOnboarding: $showOnboarding,
                        nextStep: nextOnboardingStep,
                        backStep: backOnboardingStep,
                        showBackButton: true,
                        isSecondStep: false
                    )
                    .onAppear { currentTab = .messages }
                default:
                    EmptyView()
                }
            }
        }
    }

    func nextOnboardingStep() {
        if currentOnboardingStep < 4 {
            currentOnboardingStep += 1 // Move to step 2 (FYP Page)
        } else {
            finishOnboarding()
        }
    }
    
    func backOnboardingStep() {
        if currentOnboardingStep > 1 {
            currentOnboardingStep -= 1 // Move to step 1 (Home Page)
            //currentTab = (currentOnboardingStep - 1) % 3
        }
    }
    
    func finishOnboarding() {
        withAnimation {
            showOnboarding = true // End onboarding with animation
        }
        UserDefaults.standard.set(true, forKey: "userWasOnboarded") // Save to UserDefaults
    }
}

struct Introduction: View {
    var page: String
    var title: String
    var description: String
    var description2: String
    var buttonText: String
    @Binding var showOnboarding: Bool
    var nextStep: () -> Void
    var backStep: () -> Void
    var showBackButton: Bool = false
    var isSecondStep: Bool = false
    
    // Animation states
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Enhanced blurred background
            Color.black.opacity(0.25)  // Increased opacity for better contrast
                .blur(radius: 1.0)    // Increased blur
                .edgesIgnoringSafeArea(.all)
            
            // Content card
            VStack(spacing: 25) {  // Reduced spacing slightly
                // Enhanced progress dots
                HStack(spacing: 10) {  // Increased spacing between dots
                    ForEach(1...4, id: \.self) { step in
                        Circle()
                            .fill(Int(page.prefix(1)) ?? 0 >= step ? skyBlueColor.skyBlue : Color.gray.opacity(0.6))
                            .frame(width: 10, height: 10)  // Increased size
                            .shadow(color: Int(page.prefix(1)) ?? 0 >= step ? skyBlueColor.skyBlue.opacity(0.3) : .clear, radius: 4)
                            .animation(.spring(), value: page)
                    }
                }
                .padding(.top, 45)
                
                Spacer()
                
                // Updated icons with enhanced styling
                if isSecondStep {
                    HStack {
                        Image(systemName: "pencil.slash")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.red)
                            .rotationEffect(.degrees(15))
                            .shadow(color: .red.opacity(0.4), radius: 12)
                        
                        Spacer().frame(width: 50)  // Increased spacing
                        
                        Image(systemName: "pencil.and.list.clipboard")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(skyBlueColor.skyBlue)
                            .rotationEffect(.degrees(-15))
                            .shadow(color: skyBlueColor.skyBlue.opacity(0.9), radius: 12)
                    }
                    .padding(35)
                } else {
                    Image(systemName: getSystemImageName())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)  // Slightly larger
                        .foregroundStyle(skyBlueColor.skyBlue)
                        .shadow(color: skyBlueColor.skyBlue.opacity(0.4), radius: 12)
                        .padding(35)
                }
                
                // Enhanced title and descriptions
                VStack(spacing: 22) {  // Increased spacing
                    Text(title)
                        .font(Font.custom("helvetica-bold", size: 25))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(Font.custom("helvetica", size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.95))  // Increased opacity
                        .padding(.horizontal, 25)
                    
                    Text(description2)
                        .font(Font.custom("helvetica", size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))  // Increased opacity
                        .padding(.horizontal, 25)
                }
                .padding()
                
                Spacer()
                
                // Enhanced navigation buttons
                HStack {
                    if showBackButton {
                        Button(action: backStep) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .semibold))  // Larger
                                .foregroundColor(.white)
                                .frame(width: 55, height: 55)  // Larger touch target
                                .background(Color.white.opacity(0.25))  // More visible
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 8)
                        }
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    Button(action: nextStep) {
                        HStack {
                            Text(buttonText)
                                .font(.system(size: 19, weight: .semibold))  // Larger
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(skyBlueColor.skyBlue)
                        .clipShape(Capsule())
                        .shadow(color: skyBlueColor.skyBlue.opacity(0.4), radius: 12)
                    }
                }
                .padding(.bottom, 45)
                .padding(.horizontal, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 35)  // Increased corner radius
                    .fill(Color(UIColor.systemBackground).opacity(0.12))  // Slightly more opaque
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
            )
            .padding(.horizontal, 20)
        }
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1
                offset = 0
            }
        }
    }
    
    private func getSystemImageName() -> String {
        switch Int(page.prefix(1)) ?? 0 {
        case 1: return "pencil.and.list.clipboard"
        case 2: return "square.stack.fill"
        case 3: return "message.fill"
        case 4: return "checkmark.circle.fill"
        default: return "house.fill"
        }
    }
}

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case fypPage = "Fyp Page"
    case messages = "Messages"
    
    var symbolImage: String {
        switch self {
        case .dashboard: return "pencil.and.list.clipboard"
        case .fypPage: return "clipboard"
        case .messages: return "message"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

struct InteractiveTabBar: View {
    @Binding var currentTab: TabItem
    @Namespace private var animation
    @State private var activeDraggingTab: TabItem?
    @State private var tabButtonLocations: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 40)
        .padding(5)
        .background {
            Capsule()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
        }
        .coordinateSpace(name: "TABBAR")
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? currentTab) == tab
        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .symbolVariant(.fill)
                .foregroundStyle(isActive ? .white : .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            if isActive {
                Capsule()
                    .fill(.blue.gradient)
                    .matchedGeometryEffect(id: "CURRENTTAB", in: animation)
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    let frame = geometry.frame(in: .named("TABBAR"))
                    tabButtonLocations[tab.index] = frame
                }
            }
        )
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.snappy) {
                currentTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("TABBAR"))
                .onChanged { value in
                    let location = value.location
                    if let lindex = tabButtonLocations.firstIndex(where: { $0.contains(location) }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[lindex]
                        }
                    }
                }.onEnded { _ in
                    if let activeDraggingTab {
                        currentTab = activeDraggingTab
                    }
                    activeDraggingTab = nil
                },
            isEnabled: currentTab == tab
        )
    }
}

#Preview {
    Home()
        .environmentObject(UserManager())
        .environmentObject(AuthService())
}


