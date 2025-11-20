//
//  Objects.swift
//  JobsMatch
//
//  Created by ivans Android on 3/24/24.
//

import Foundation
import SwiftUI

struct skyBlueColor {
    static let skyBlue = Color(red: 0.329, green: 0.514, blue: 0.820)
}

struct CustomLoadingView: View {
    @State private var isRotating = false
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 2.5)
                .frame(width: 25, height: 25)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, lineWidth: 2.5)
                .frame(width: 25, height: 25)
                .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRotating)
                .onAppear {
                    isRotating = true
                }
        }
    }
}


class hostAddressClass: ObservableObject{
    @Published var streetAddress = ""
    @Published var city = ""
    @Published var state = ""
    @Published var zip = ""
}

struct jobListing: Identifiable, Equatable {
    let id = UUID()
    var jobField: String
    var jobPosition: String
    var jobWorkType: String
    var jobCompanyName: String
    var jobLocation: String
    var jobSalary: String
    var jobRequiremnets: String
    var jobCompanyBio: String
    
    // Add other event properties here (e.g., startTime, endTime)
}



struct dividerWithLabel: View {
    let label: String
    var lineColor: Color = .gray
    var lineOpacity: Double = 0.5
    var lineHeight: CGFloat = 1
    var textFont: Font = Font.custom("helvetica-bold", size: 15)
    var textColor: Color = .black
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .foregroundStyle(lineColor)
                .opacity(lineOpacity)
                .frame(height: lineHeight)
            
            Text(label)
                .font(textFont)
                .foregroundColor(textColor)
                .fixedSize()
            
            Rectangle()
                .foregroundStyle(lineColor)
                .opacity(lineOpacity)
                .frame(height: lineHeight)
        }
        .padding(.horizontal, 16)
    }
}

class jobStore: ObservableObject {
    @Published var Jobs: [jobListing] = []
    
    func addEvent(_ job: jobListing) {
        Jobs.append(job)
    }
}
