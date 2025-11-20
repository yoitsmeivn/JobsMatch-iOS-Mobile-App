//
//  hostMessages.swift
//  JobsMatch
//
//  Created by ivans Android on 5/22/24.
//


import SwiftUI
import SendbirdChatSDK
import SendbirdUIKit
import FirebaseFirestore

class ChannelManager: ObservableObject {
    @Published var channels: [GroupChannel] = []
    
    func fetchChannels(for userId: String) {
        let listQuery = GroupChannel.createMyGroupChannelListQuery { query in
            query.order = .latestLastMessage
            query.limit = 15
        }
        
        listQuery.loadNextPage { [weak self] (channels, error) in
            if let error = error {
                print("Error loading channels: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self?.channels = channels ?? []
            }
        }
    }

    func addChannel(_ channel: GroupChannel) {
        DispatchQueue.main.async {
            if !self.channels.contains(where: { $0.channelURL == channel.channelURL }) {
                self.channels.insert(channel, at: 0)
            }
        }
    }
}


struct hostMessages: View {
    @EnvironmentObject var authServiceHost: AuthServiceHost
    @StateObject private var channelManager = ChannelManager()

    var body: some View {
        Group {
            if let currentHost = authServiceHost.hostSession {
                SendbirdChannelListView(userId: currentHost.uid, channelManager: channelManager)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("No host logged in")
            }
        }
        .onAppear {
            fetchHost()
        }
    }

    private func fetchHost() {
        Task {
            if let hostSession = authServiceHost.hostSession {
                authServiceHost.fetchCurrentHost(for: hostSession.uid)
                channelManager.fetchChannels(for: hostSession.uid)
            }
        }
    }
}

struct hostMessages_Previews: PreviewProvider {
    static var previews: some View {
        hostMessages()
            .environmentObject(AuthServiceHost.shared)
    }
}
