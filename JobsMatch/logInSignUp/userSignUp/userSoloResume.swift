//
//  userSoloResume.swift
//  JobsMatch
//
//  Created by ivans Android on 2/6/25.
//

import SwiftUI
import FirebaseStorage
import AppTrackingTransparency
import AdSupport

struct FireworkParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var rotation: Double
    var offset: CGSize
}

struct ResumeFireworkAnimation: View {
    let centerPoint: CGPoint
    @Binding var isAnimating: Bool
    @State private var particles: [FireworkParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: "pencil.and.list.clipboard")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.black)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.position.x + particle.offset.width,
                            y: particle.position.y + particle.offset.height)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        particles = (0..<16).map { index in
            FireworkParticle(
                position: centerPoint,
                scale: 1.0,
                opacity: 1.0,
                rotation: Double(index) * (360.0 / 16),
                offset: .zero
            )
        }
        
        withAnimation(.easeOut(duration: 0.8)) {
            for index in particles.indices {
                let angle = Double(index) * (360.0 / Double(particles.count))
                let distance: CGFloat = 200
                let radians = angle * .pi / 180
                
                particles[index].offset = CGSize(
                    width: cos(radians) * distance,
                    height: sin(radians) * distance
                )
                particles[index].scale = 0.2
                particles[index].opacity = 0
                particles[index].rotation += Double.random(in: -360...360)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            particles.removeAll()
            isAnimating = false
        }
    }
}

struct userSoloResume: View {
    @State private var navigateToNextView = false
    @Environment(\.dismiss) private var dismiss
    @State private var showFireworkAnimation = false
    @State private var buttonCenter: CGPoint = .zero
    
    @State private var resume: URL?
    @State private var presentImporter = false
    @State private var fileName = ""
    
    var isFormValid: Bool {
        resume != nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 3){
                    ZStack {
                        // HStack for the dismiss button aligned to the left
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            Spacer() // This pushes the button to the left
                        }
                        // Centered image
                        Image("WaveJustLogoWhite")
                            .resizable()
                            .frame(width: 150, height: 125)
                            .padding(.top)
                    }
                    .padding(.bottom)
                    VStack(spacing: 10) {
                        Spacer(minLength: 60)
                        
                        VStack(spacing: 12) {
                            Text("Upload Your Resume")
                                .font(Font.custom("helvetica-bold", size: 28))
                                .foregroundColor(.black)
                            
                            Text("Swipe To Apply with your Resume")
                                .font(Font.custom("helvetica", size: 16))
                                .foregroundColor(.black.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack {
                            Text("Upload Resume (PDF Only)")
                                .foregroundStyle(.black)
                                .font(Font.custom("helvetica-bold", size: 15))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top)
                            uploadResumeButton
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 30)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ButtonPositionPreferenceKey.self,
                                                        value: CGPoint(
                                                            x: geo.frame(in: .global).midX,
                                                            y: geo.frame(in: .global).midY
                                                        ))
                                    }
                                )
                        }
                        .padding()
                    }
                    
                    Image("arrow")
                        .resizable()
                        .frame(width: 200, height: 250)
                        .rotationEffect(.degrees(175))
                    
                    Button(action: {
                        saveUserData4()
                        navigateToNextView = true
                        print(fileName)
                    }) {
                        Text("Continue")
                            .font(Font.custom("helvetica-bold", size: 18))
                            .opacity(3)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 40)
                            .background(Color.black.opacity(isFormValid ? 1.0 : 0.5))
                            .cornerRadius(10)
                            .padding()
                            .padding(.bottom)
                    }
                    .disabled(!isFormValid)
                    .navigationDestination(isPresented: $navigateToNextView) {
                        userPassword()
                    }
                }
                
                if showFireworkAnimation {
                    ResumeFireworkAnimation(
                        centerPoint: CGPoint(x: buttonCenter.x, y: buttonCenter.y - 50),
                        isAnimating: $showFireworkAnimation
                    )
                    .allowsHitTesting(false)
                }
            }
            .onPreferenceChange(ButtonPositionPreferenceKey.self) { position in
                buttonCenter = position
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // Define the preference key to get button position
    struct ButtonPositionPreferenceKey: PreferenceKey {
        static var defaultValue: CGPoint = .zero
        
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            value = nextValue()
        }
    }
    
    // MARK: - Haptic Feedback Function
    private func triggerHapticFeedback() {
        // Use success haptic feedback for a satisfying vibration
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Alternative: You can also use success notification feedback
        // let notificationFeedback = UINotificationFeedbackGenerator()
        // notificationFeedback.notificationOccurred(.success)
    }
    
    func saveUserData4() {
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
    
    private var uploadResumeButton: some View {
        Button(action: {
            presentImporter.toggle()
        }) {
            HStack {
                Image(systemName: resume != nil ? "checkmark" : "paperclip")
                Text(resume != nil ? fileName : "Attach Resume")
                    .font(Font.custom("helvetica", size: 15))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .foregroundColor(.black)
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 20).fill(.white).stroke(Color.black, lineWidth: 3))
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
                    
                    // Trigger haptic feedback immediately when file is selected
                    triggerHapticFeedback()
                    
                    // Trigger animation after a slight delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            showFireworkAnimation = true
                        }
                    }
                    
                    guard file.startAccessingSecurityScopedResource() else {
                        print("Failed to access security-scoped resource")
                        return
                    }
                    
                    defer {
                        file.stopAccessingSecurityScopedResource()
                    }
                    
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsDirectory.appendingPathComponent(file.lastPathComponent)
                    
                    do {
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        
                        try FileManager.default.copyItem(at: file, to: destinationURL)
                        
                        fileName = file.lastPathComponent
                        resume = destinationURL
                        
                        UserDefaults.standard.set(destinationURL.path, forKey: "resumePath")
                        
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
}

#Preview {
    userSoloResume()
}
