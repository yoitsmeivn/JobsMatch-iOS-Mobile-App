////  careerInsights.swift
//  JobsMatch
//
//  Created by ivans Android on 6/6/25.
//

import SwiftUI

struct CareerInsightsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateContent = false
    @Binding var currentTab: TabItem
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4),
                        Color(red: 0.3, green: 0.2, blue: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 25) {
                        // Header section
                        VStack(spacing: 20) {
                            // Analytics icon
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60, weight: .medium))
                                .foregroundColor(.white)
                                .opacity(animateContent ? 1 : 0)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                            
                            // Title
                            Text("Career Insights")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            
                            // Description
                            Text("Get personalized insights about your job search progress, market trends, and career opportunities.")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.5), value: animateContent)
                            
                            // Coming Soon badge
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                
                                Text("Coming Q3 2025")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .opacity(animateContent ? 1 : 0)
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .animation(.easeOut(duration: 0.6).delay(0.7), value: animateContent)
                        }
                        .padding(.top, 40)
                        
                        // Features section
                        VStack(spacing: 24) {
                            // Application Analytics
                            FeatureCard(
                                icon: "chart.bar.fill",
                                iconColor: Color(red: 0.2, green: 0.8, blue: 0.4),
                                title: "Application Analytics",
                                description: "Track your application success rates, response times, and optimize your job search strategy."
                            )
                            .opacity(animateContent ? 1 : 0)
                            .offset(x: animateContent ? 0 : -30)
                            .animation(.easeOut(duration: 0.6).delay(0.9), value: animateContent)
                            
                            // Market Trends
                            FeatureCard(
                                icon: "target",
                                iconColor: Color(red: 0.6, green: 0.4, blue: 0.9),
                                title: "Market Trends",
                                description: "Stay informed about salary trends, in-demand skills, and hiring patterns in your field."
                            )
                            .opacity(animateContent ? 1 : 0)
                            .offset(x: animateContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(1.1), value: animateContent)
                        }
                        .padding(.horizontal, 20)
                        
                        // Early access section
                        VStack(spacing: 16) {
                            Text("Want early access?")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(1.3), value: animateContent)
                            
                            Text("Keep exploring jobs and we'll notify you when Career Insights launches!")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(1.5), value: animateContent)
                            
                            Button(action: {
                                // Switch to fypPage tab and dismiss
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentTab = .fypPage
                                }
                                dismiss()
                            }) {
                                Text("Explore Jobs")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.4, green: 0.6, blue: 1.0),
                                                        Color(red: 0.6, green: 0.4, blue: 0.9)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    )
                            }
                            .padding(.horizontal, 40)
                            .opacity(animateContent ? 1 : 0)
                            .scaleEffect(animateContent ? 1 : 0.9)
                            .animation(.easeOut(duration: 0.6).delay(1.7), value: animateContent)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                animateContent = true
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
