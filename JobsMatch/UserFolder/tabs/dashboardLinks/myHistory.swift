//
//  myHistory.swift
//  JobsMatch
//
//  Created by ivans Android on 6/19/24.
//

import SwiftUI
import FirebaseFirestore

struct myHistory: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSegment = 0
    @StateObject private var viewModel = MyJobsViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                }
                .padding()
                
                BubblePickerView(selectedCategoryIndex: $selectedSegment, scrollOffset: .constant(0), maxHeight: 80)
                    .padding(.horizontal)
                if selectedSegment == 0 {
                    AcceptedJobsView(viewModel: viewModel)
                } else {
                    RejectedJobsView(viewModel: viewModel)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let userId = authService.currentUser?.id {
                viewModel.fetchAcceptedJobs(for: userId)
                viewModel.fetchDeniedJobs(for: userId)
            }
        }
    }
}

struct AcceptedJobsView: View {
    @ObservedObject var viewModel: MyJobsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Accepted Jobs")
                    .font(Font.custom("Orkney-Bold", size: 30))
                    .padding(.leading)
                
                if viewModel.isLoading {
                    CustomLoadingView(color: skyBlueColor.skyBlue)
                        .frame(width: 25, height: 25)
                } else if viewModel.acceptedJobs.isEmpty {
                    Spacer()
                    VStack{
                        Image("nomore")
                            .resizable()
                            .frame(width:300,height:200)
                            .padding()
                        Text("Let's Swipe Some More!")
                            .font(.custom("helvetica-bold", size: 20))
                            .foregroundColor(.black)
                    }
                } else {
                    ForEach(viewModel.acceptedJobs) { job in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("")
                                    .font(Font.custom("Orkney-Bold", size: 14))
                                Spacer()
                                Text("Status: Accepted")
                                    .font(Font.custom("Orkney-Bold", size: 14))
                                    .foregroundColor(.green)
                            }
                            
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }
            .padding(.top)
        }
    }
}

struct RejectedJobsView: View {
    @ObservedObject var viewModel: MyJobsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Rejected Jobs")
                    .font(Font.custom("Orkney-Bold", size: 30))
                    .padding(.leading)
                
                if viewModel.isLoading {
                    CustomLoadingView(color: skyBlueColor.skyBlue)
                        .frame(width: 25, height: 25)
                } else if viewModel.deniedJobs.isEmpty {
                    Spacer()
                    VStack{
                        Image("nomore")
                            .resizable()
                            .frame(width:300,height:200)
                            .padding()
                        Text("Nothing Here")
                            .font(.custom("Orkney-Bold", size: 20))
                            .foregroundColor(.black)
                    }
                } else {
                    ForEach(viewModel.deniedJobs) { job in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("")
                                    .font(Font.custom("Orkney-Bold", size: 14))
                                Spacer()
                                Text("Status: Rejected")
                                    .font(Font.custom("Orkney-Bold", size: 14))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }
            .padding(.top)
        }
    }
}

struct BubblePickerView: View {
    let categories = ["Accepted", "Rejected"]
    @Binding var selectedCategoryIndex: Int
    @Binding var scrollOffset: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        HStack {
            ForEach(0..<categories.count, id: \.self) { index in
                Button(action: {
                    self.selectedCategoryIndex = index
                }) {
                    Text(self.categories[index])
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(self.selectedCategoryIndex == index ? skyBlueColor.skyBlue : Color.clear)
                        .foregroundColor(self.selectedCategoryIndex == index ? .white : skyBlueColor.skyBlue)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(skyBlueColor.skyBlue, lineWidth: 2)
                        )
                }
                .animation(.easeInOut, value: selectedCategoryIndex)
            }
        }
        .frame(maxHeight: maxHeight)
    }
}

struct myHistory_Previews: PreviewProvider {
    static var previews: some View {
        myHistory()
            .environmentObject(AuthService())
    }
}
