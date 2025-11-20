//
//  hostCompleteView.swift
//  JobsMatch
//
//  Created by ivans Android on 4/22/24.
//

import SwiftUI

struct slideToUnlockHostView: View {
    @State private var dragAmount = CGSize.zero
    @State private var progress: CGFloat = 0.0
    private let maxDragAmount: CGFloat = 70
    @Binding var showSlideToUnlockHostView: Bool
    var body: some View {
        ZStack{
            skyBlueColor.skyBlue
                .ignoresSafeArea()
            VStack(spacing:30){
                HStack{
                    Image("JobsMatchBluebackground")
                        .resizable()
                        .frame(width:200,height:55)
                        .padding(.bottom)
                    Spacer()
                }
                .padding()
                Spacer()
                progressView
                    .scaleEffect(max(1 + progress / 10,1))
                welcomeView
                Spacer()
                slideView
            }
        }
    }
    var progressView: some View{
        ZStack{
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.black,style: StrokeStyle(lineWidth: 8,lineCap: .round,lineJoin: .round))
                .frame(width:70,height:70)
                .rotationEffect(.degrees(-90))
                .background(
                    Circle()
                        .stroke(lineWidth: 8)
                        .foregroundStyle(.white)
                )
            Image(systemName:"checkmark").bold()
                .font(.system(size:45))
                .foregroundStyle(.black)
        }
        .rotationEffect(.degrees(10),anchor: .bottomTrailing)
    }
    
    var welcomeView: some View{
        VStack(spacing: 30){
            Text("Welcome to Jobs Match")
                .foregroundStyle(.black)
                .font(Font.custom("Orkney-Bold", size: 25))
            Text("Reinventing the Job Application")
                .foregroundStyle(.black)
                .font(Font.custom("Orkney-Regular", size: 19))
                .multilineTextAlignment(.center)
        }
    }
    
    var slideView: some View{
        HStack{
            Text("Slide to Complete")
            Image(systemName: "arrow.forward")
            
        }
        .foregroundStyle(.secondary)
        .font(.title2)
        .bold()
        .offset(x: max(0,dragAmount.width))
        .gesture(
            DragGesture()
                .onChanged{ value in
                    withAnimation{
                        let translationWidth = value.translation.width
                        self.dragAmount.width = min(translationWidth , maxDragAmount)
                        self.progress = min(1,self.dragAmount.width / maxDragAmount)
                    }
                }
                .onEnded{ _ in
                    if self.progress >= 1{
                        withAnimation {
                            self.dragAmount = .zero
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            withAnimation{
                                showSlideToUnlockHostView = true
                            }
                        }
                    }else{
                        withAnimation(.linear){
                            self.dragAmount = .zero
                            self.progress = 0
                        }
                    }
                })
        .navigationBarBackButtonHidden(true)
    }
    
}




#Preview {
    slideToUnlockHostView(showSlideToUnlockHostView: .constant(false))
}
