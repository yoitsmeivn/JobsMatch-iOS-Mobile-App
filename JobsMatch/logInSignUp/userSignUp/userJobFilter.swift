import SwiftUI

struct userJobFilter: View {
    let interests = ["Software", "Engineering", "Marketing", "Business", "Biology", "Food Service"]
    @State var selectedInterests = Set<String>()
    @State private var navigateToNextView = false
    @Environment(\.dismiss) private var dismiss
    
    var isFormValid: Bool {
        !selectedInterests.isEmpty
    }

    var body: some View {
        ZStack {
            skyBlueColor.skyBlue
                .ignoresSafeArea()
            VStack(spacing: 10) {
                HStack {
                    Image("JobsMatchBluebackground")
                        .resizable()
                        .frame(width: 200, height: 55)
                        .padding(.bottom)
                    Spacer()
                }
                .padding()
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName:"chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color.black)
                            .padding()
                    }
                    Spacer()
                }
                Text("Your Area of Expertise")
                    .foregroundStyle(.black)
                    .font(Font.custom("Orkney-Bold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                Spacer()

                ScrollView {
                    let columns = [
                        GridItem(.flexible(), spacing: -10),
                        GridItem(.flexible(), spacing: -10),
                        GridItem(.flexible(), spacing: -10)
                    ]

                    LazyVGrid(columns: columns, alignment: .center, spacing: 15) {
                        ForEach(interests, id: \.self) { interest in
                            InterestSquare(interest: interest, isSelected: selectedInterests.contains(interest)) {
                                withAnimation {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.remove(interest)
                                    } else {
                                        selectedInterests.insert(interest)
                                    }
                                }
                            }
                            .frame(width: 115, height: 145)
                            .background(isSelected(interest: interest) ? Color.black : Color.white.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            .foregroundColor(isSelected(interest: interest) ? skyBlueColor.skyBlue : Color.black)
                        }
                    }
                }
                .padding(.top)
                Spacer()
                Button(action: {
                    saveUserData3()
                    navigateToNextView = true
                }) {
                    Text("Continue")
                        .font(Font.custom("Orkney-Bold", size: 18))
                        .opacity(1)
                        .foregroundColor(skyBlueColor.skyBlue)
                        .frame(width: 300, height: 40)
                        .background(Color.black.opacity(isFormValid ? 1.0 : 0.5))
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(!isFormValid)
            }
            .navigationBarBackButtonHidden(true)

            if navigateToNextView {
                userResume()
                    .transition(.move(edge: .trailing))
                    //.zIndex(1)
            }
        }
        .animation(.default, value: navigateToNextView)
    }

    func saveUserData3() {
        UserDefaults.standard.set(Array(selectedInterests), forKey: "interests")
    }

    private func isSelected(interest: String) -> Bool {
        selectedInterests.contains(interest)
    }
}

struct InterestSquare: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(interest)
                .font(Font.custom("Orkney-Regular", size: 15))
                .padding()
        }
    }
}

struct UserJobFilter_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            userJobFilter()
        }
    }
}
