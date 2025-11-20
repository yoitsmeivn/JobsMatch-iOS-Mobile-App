import SwiftUI

struct scrollPreKey2: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct fypPage: View {
    @State var isScroll = false
    @EnvironmentObject var authService: AuthService
    @StateObject private var jobManager: JobManager

    // Initializing the JobManager with AuthService
    init(authService: AuthService) {
        _jobManager = StateObject(wrappedValue: JobManager(authService: authService))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    GeometryReader { proxy in
                        Color.clear.preference(key: scrollPreKey2.self, value: proxy.frame(in: .named("scroll")).minY)
                    }
                    
                    VStack(alignment: .leading) {
                        // Header
                        Text("Top job picks for you")
                            .font(.system(size: 34, weight: .bold))
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .padding(.horizontal)
                        
                        Text("Find opportunities that match your skills")
                            .font(Font.custom("helvetica", size: 18))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        
                        // Job Grid
                        JobGridView()
                            .environmentObject(jobManager)
                            .padding()
                    }
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(scrollPreKey2.self) { value in
                    withAnimation(.default) {
                        isScroll = value < 0
                    }
                }
                
                // Minimalist header shadow that appears when scrolling
                if isScroll {
                    VStack {
                        Rectangle()
                            .fill(Color(.systemBackground))
                            .frame(height: 60)
                            .overlay(
                                Text("Discover Jobs")
                                    .font(Font.custom("helvetica-bold", size: 30))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: isScroll)
                }
            }
        }
        .environmentObject(authService)
    }
}
//#Preview {
//    fypPage(authService: AuthService.shared) // Ensure to pass the AuthService for the preview
//        .environmentObject(AuthService.shared)
//}
