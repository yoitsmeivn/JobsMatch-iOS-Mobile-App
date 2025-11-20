//
//  stateSelection.swift
//  JobsMatch
//
//  Created by ivans Android on 9/25/24.
//

import SwiftUI

enum ImageResource: String, Hashable {
    case starone = "starone"
    case startwo = "startwo"
    case starthree = "starthree"
    case starfour = "starfour"
    case starfive = "starfive"
    
    func image(isFilled: Bool) -> Image {
        // Return filled star for selected, and outlined star for unselected
        return Image(systemName: isFilled ? "star.fill" : "star")
    }
}

struct stateSelection: View {
    @Binding var selected: ImageResource?
    var stars: [ImageResource] = [.starone, .startwo, .starthree, .starfour, .starfive]
    
    var body: some View {
        VStack {
            // HStack to display the stars
            HStack {
                ForEach(stars, id: \.self) { item in
                    item.image(isFilled: isSelectedOrBefore(item))
                        .resizable()
                        .scaledToFit()
                        // Use skyBlueColor for selected stars, and default outline for unselected stars
                        .foregroundStyle(isSelectedOrBefore(item) ? skyBlueColor.skyBlue : Color.black)
                        .frame(width: 32, height: 32)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selected == item ? Color.white : Color.white)
                        )
                        .onTapGesture {
                            selected = item
                        }
                }
            }
        }
    }
    
    // Helper function to check if the star is selected or comes before the selected star
    func isSelectedOrBefore(_ item: ImageResource) -> Bool {
        if let selected = selected {
            return stars.firstIndex(of: item)! <= stars.firstIndex(of: selected)!
        }
        return false
    }
    
    // Function to count how many stars are selected
    func selectedStarsCount() -> Int {
        if let selected = selected {
            return stars.firstIndex(of: selected)! + 1
        }
        return 0
    }
}

#Preview {
    stateSelection(selected: .constant(nil)) // No star selected initially
}
