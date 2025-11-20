//
//  swipeIndicatorView.swift
//  JobsMatch
//
//  Created by ivans Android on 3/25/24.
//

import SwiftUI

struct swipeIndicatorView: View {
    @Binding var xOffset: CGFloat
    let screenCutOff: CGFloat
    var body: some View {
        HStack{
            Image(systemName:"pencil.and.list.clipboard")
                .resizable()
                .frame(width:80,height:80)
                .foregroundStyle(skyBlueColor.skyBlue)
                .rotationEffect(.degrees(-15))
                .opacity(Double(xOffset / screenCutOff))
            
            Spacer()
            
            Image(systemName:"pencil.slash")
                .resizable()
                .frame(width:80,height:80)
                .foregroundStyle(.red)
                .rotationEffect(.degrees(15))
                .opacity(Double(xOffset / screenCutOff) * -1)
        }
        .padding(40)
    }
}

#Preview {
    swipeIndicatorView(xOffset: .constant(20), screenCutOff: 1)
}
