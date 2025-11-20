//
//  SendAndCancel.swift
//  JobsMatch
//
//  Created by ivans Android on 9/25/24.
//

import SwiftUI

struct SendAndCancel: View {
    @Binding var send: Bool
    var Cancel: () -> Void
    var Send: () -> Void
    
    var body: some View {
        HStack(spacing: send ? 10 : 0) {
            CancelButton(send: $send, Cancel: { Cancel() })
            SendButton(send: $send, Send: { Send() })
        }
        .padding()
    }
}

struct CancelButton: View {
    @Binding var send: Bool
    var Cancel: () -> Void
    
    var body: some View {
        Button(action: {
            Cancel()
        }) {
            Image(systemName: "xmark")
                .font(.title2)
                // Conditional size based on send state
                .frame(maxWidth: send ? 60 : .infinity)
                .frame(height: 60)
                .background(Color.black) // Replace `.bg` with `Color.gray` or your custom color
                .cornerRadius(10.0)
        }
        .tint(.white)
    }
}

struct SendButton: View {
    @Binding var send: Bool
    var Send: () -> Void
    
    var body: some View {
        Button(action: {
            Send()
        }) {
            Text("Submit")
                .font(Font.custom("Orkney-Bold", size: 15))
                .foregroundStyle(.white)
                // Conditional size based on send state
                .frame(maxWidth: send ? .infinity : 0)
                .frame(height: 60)
                .background(skyBlueColor.skyBlue) // Replace `.bg` with `Color.gray` or your custom color
                .cornerRadius(10.0)
        }
    }
}

#Preview {
    SendAndCancel(send: .constant(false), Cancel: {}, Send: {})
}
