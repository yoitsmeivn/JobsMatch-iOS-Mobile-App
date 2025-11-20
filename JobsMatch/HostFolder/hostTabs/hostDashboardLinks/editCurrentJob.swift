//
//  editCurrentJob.swift
//  JobsMatch
//
//  Created by ivans Android on 5/20/24.
//

import SwiftUI

struct editCurrentJob: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            ScrollView{
                Text("Your Job Listing")
                    .font(Font.custom("Orkney-Bold", size: 30))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                VStack(spacing:-5){
                    //user info divider
                    dividerWithLabel(label: "Job Information")
                        .padding()
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Edit Listing")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .foregroundColor(skyBlueColor.skyBlue)
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button("Done"){
                        dismiss()
                    }
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .foregroundColor(skyBlueColor.skyBlue)
                }
                    
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    editCurrentJob()
}
