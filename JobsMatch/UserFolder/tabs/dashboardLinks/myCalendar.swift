//
//  myCalendar.swift
//  JobsMatch
//
//  Created by ivans Android on 7/21/24.
//



import SwiftUI
import FirebaseFirestore

struct myCalendar: View {
    @State private var currentMonth: Date
    @State private var showEventSheet = false
    @State private var selectedEvent: AppointmentData?
    @State private var appointments: [AppointmentData] = []
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    
    private let calendar = Calendar.current
    private let db = Firestore.firestore()

    init() {
        let now = Date()
        self._currentMonth = State(initialValue: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: now))!)
    }

    // Model for appointment data
    struct AppointmentData: Identifiable {
        let id: String
        let applicantEmail: String
        let aptDate: Date
        let aptTime: String
        let aptNotes: String
        
        init?(document: QueryDocumentSnapshot) {
            guard let aptDateString = document.data()["apt_date"] as? String,
                  let aptTime = document.data()["apt_time"] as? String,
                  let applicantEmail = document.data()["applicant_email"] as? String else {
                return nil
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            guard let date = dateFormatter.date(from: aptDateString) else { return nil }
            
            self.id = document.documentID
            self.applicantEmail = applicantEmail
            self.aptDate = date
            self.aptTime = aptTime
            self.aptNotes = document.data()["apt_notes"] as? String ?? ""
        }
    }

    var body: some View {
        VStack {
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
            .padding()
            
            Text("Calendar")
                .font(Font.custom("Orkney-Bold", size: 30))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.skyBlue)
                        .padding()
                }

                Text("\(currentMonth, formatter: monthYearFormatter)")
                    .font(.title)
                    .padding()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.skyBlue)
                        .padding()
                }
            }

            let days = generateDaysInMonth(for: currentMonth)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { date in
                    VStack {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.headline)
                            .frame(width: 40, height: 40)
                            .background(isToday(date) ? Color.lightBlue : (hasAppointment(on: date) ? Color.skyBlue : Color.clear))
                            .cornerRadius(20)
                            .foregroundColor(isToday(date) || hasAppointment(on: date) ? .white : .primary)
                            .onTapGesture {
                                if let appointment = getAppointment(for: date) {
                                    selectedEvent = appointment
                                    showEventSheet = true
                                }
                            }
                            .disabled(!hasAppointment(on: date))
                    }
                }
            }
            .padding()
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showEventSheet) {
            if let event = selectedEvent {
                VStack {
                    Text("Appointment Details")
                        .font(.title)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Date: \(event.aptDate, formatter: dateFormatter)")
                        Text("Time: \(event.aptTime)")
                        Text("Email: \(event.applicantEmail)")
                        if !event.aptNotes.isEmpty {
                            Text("Notes: \(event.aptNotes)")
                        }
                    }
                    .padding()
                    
                    Button("Close") {
                        showEventSheet = false
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            if let userId = authService.currentUser?.id {
                fetchAppointments(for: userId)
            }
        }
    }

    private func fetchAppointments(for userId: String) {
        db.collection("appointments")
            .whereField("applicant_ref", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching appointments: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                appointments = documents.compactMap { AppointmentData(document: $0) }
            }
    }

    private func hasAppointment(on date: Date) -> Bool {
        return appointments.contains { appointment in
            calendar.isDate(appointment.aptDate, inSameDayAs: date)
        }
    }

    private func getAppointment(for date: Date) -> AppointmentData? {
        return appointments.first { appointment in
            calendar.isDate(appointment.aptDate, inSameDayAs: date)
        }
    }

    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = newMonth
    }

    private func generateDaysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        
        var days: [Date] = []
        var day = monthInterval.start
        
        while day < monthInterval.end {
            days.append(day)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }
        
        return days
    }

    private func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// Extension to add colors
extension Color {
    static let lightBlue = Color(red: 0.68, green: 0.85, blue: 0.90)
    static let skyBlue = Color(red: 0.4, green: 0.8, blue: 1.0)
}

struct myCalendar_Previews: PreviewProvider {
    static var previews: some View {
        myCalendar()
            .environmentObject(AuthService())
    }
}
