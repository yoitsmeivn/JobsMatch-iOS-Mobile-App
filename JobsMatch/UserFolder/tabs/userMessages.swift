//
//  userMessages.swift
//  JobsMatch
//
//  Created by ivans Android on 3/24/24.
//
import SwiftUI
import SendbirdChatSDK
import SendbirdUIKit

// Wrapper for Sendbird's UIKit view controllers



struct SendbirdChannelListView: UIViewControllerRepresentable {
    var userId: String
    @ObservedObject var channelManager: ChannelManager
    
    func makeUIViewController(context: Context) -> UIViewController {
        let skyBlueUIColor = UIColor(skyBlueColor.skyBlue)
        
        
        
        
        let channelTheme = SBUChannelTheme(
            statusBarStyle: .default, navigationBarTintColor: skyBlueUIColor,
            leftBarButtonTintColor: SBUColorSet.onLightTextHighEmphasis,
            rightBarButtonTintColor: SBUColorSet.onLightTextHighEmphasis,
            cancelItemColor: SBUColorSet.primaryLight,
            alertCancelColor: SBUColorSet.primaryLight,
            menuTextColor: SBUColorSet.onLightTextHighEmphasis,
            channelStateBannerFont: UIFont(name: "helvetica-bold", size: 14) ?? UIFont.systemFont(ofSize: 14),
            channelStateBannerTextColor: SBUColorSet.onLightTextHighEmphasis,
            channelStateBannerBackgroundColor: SBUColorSet.background200
            
            // Set other necessary theme properties.
        )

        
        let messageInputTheme = SBUMessageInputTheme(
            textFieldPlaceholderColor: SBUColorSet.onLightTextLowEmphasis,
            textFieldPlaceholderFont: UIFont(name: "helvetica-bold", size: 14) ?? UIFont.systemFont(ofSize: 14),
            textFieldDisabledColor: SBUColorSet.onLightTextDisabled,
            textFieldTintColor: SBUColorSet.primaryMain,
            textFieldTextColor: SBUColorSet.onLightTextHighEmphasis,
            textFieldBorderColor: SBUColorSet.onLightTextMidEmphasis,
            buttonTintColor: skyBlueUIColor,
            buttonDisabledTintColor: SBUColorSet.onLightTextDisabled,
            cancelButtonFont: UIFont(name: "helvetica-bold", size: 14) ?? UIFont.systemFont(ofSize: 14),
            saveButtonFont: UIFont(name: "helvetica-bold", size: 14) ?? UIFont.systemFont(ofSize: 14),
            saveButtonTextColor: skyBlueUIColor
            
        )
        
        let messageCellTheme = SBUMessageCellTheme(
            leftBackgroundColor: UIColor.systemGray5,
            leftPressedBackgroundColor: UIColor.systemGray4,
            rightBackgroundColor: skyBlueUIColor,
            rightPressedBackgroundColor: skyBlueUIColor.withAlphaComponent(0.8)
            
            //readReceiptFont: UIFont.systemFont(ofSize: 12)
        )
        
        
        let channelListTheme = SBUGroupChannelListTheme(
            leftBarButtonTintColor: skyBlueUIColor,
            rightBarButtonTintColor: skyBlueUIColor,
            navigationBarTintColor: skyBlueUIColor
        )

        // Set component theme
        let componentTheme = SBUComponentTheme(
            emptyViewBackgroundColor: .white,
            menuTitleFont: SBUFontSet.subtitle1
        )

        // Create and configure SBUGroupChannelCellTheme
        let channelCellTheme = SBUGroupChannelCellTheme(
            backgroundColor: SBUColorSet.background50,
            titleFont: SBUFontSet.subtitle1,
            titleTextColor: SBUColorSet.onLightTextHighEmphasis,
            memberCountFont: SBUFontSet.caption2, memberCountTextColor: SBUColorSet.onLightTextLowEmphasis, lastUpdatedTimeFont: SBUFontSet.body3,
            lastUpdatedTimeTextColor: SBUColorSet.onLightTextLowEmphasis,
            messageFont: SBUFontSet.caption1,
            messageTextColor: SBUColorSet.onDarkTextHighEmphasis,
            fileIconBackgroundColor: SBUColorSet.secondaryMain,
            fileIconTintColor: SBUColorSet.secondaryMain,
            unreadCountBackgroundColor: skyBlueUIColor
        )
        


        // Set new theme
        let newTheme = SBUTheme(
            groupChannelListTheme: channelListTheme,
            groupChannelCellTheme: channelCellTheme,
            channelTheme: channelTheme, messageInputTheme: messageInputTheme, messageCellTheme: messageCellTheme, componentTheme: componentTheme
        )
        
        
        SBUTheme.set(theme: newTheme)
        
        let channelListVC = SBUViewControllerSet.GroupChannelListViewController.init()
        
        
        class CustomViewController: UIViewController {
            var userId: String?
            var hostId: String?
            
            let channelListVC: SBUGroupChannelListViewController
            let channelManager: ChannelManager
            let chatManager: ChatManager
            
            init(channelListVC: SBUGroupChannelListViewController, channelManager: ChannelManager,chatManager: ChatManager) {
                self.channelListVC = channelListVC
                self.channelManager = channelManager
                self.chatManager = chatManager
                super.init(nibName: nil, bundle: nil)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func viewDidLoad() {
                super.viewDidLoad()
                // Add the channel list view controller as a child
                addChild(channelListVC)
                view.addSubview(channelListVC.view)
                channelListVC.view.frame = view.bounds
                channelListVC.didMove(toParent: self)
                //title = "Messages"
                
                _ = UIColor(skyBlueColor.skyBlue)
                // Hide the back button
                navigationItem.hidesBackButton = true
                NotificationCenter.default.addObserver(self, selector: #selector(handleNewChannel(_:)), name: NSNotification.Name("NewChannelCreated"), object: nil)
                
                
                //navigationItem.title = "Messages"
                                
                // Configure the navigation bar
                if let navigationBar = navigationController?.navigationBar {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = .white
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    
                    navigationBar.standardAppearance = appearance
                    navigationBar.scrollEdgeAppearance = appearance
                    navigationBar.compactAppearance = appearance
                    
                    // Set the title color and position
                    navigationItem.largeTitleDisplayMode = .always
                    let titleLabel = UILabel()
                    titleLabel.text = "Messages"
                    titleLabel.textColor = .white
                    titleLabel.font = UIFont(name: "helvetica-bold", size: 35) ?? UIFont.systemFont(ofSize: 14)
                    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
                }
                
                // Set the background color to white
                view.backgroundColor = .white
                channelListVC.view.backgroundColor = .white

                
                
                
                /*
                if let navigationBar = navigationController?.navigationBar {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = skyBlueUIColor1
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                    navigationBar.standardAppearance = appearance
                    navigationBar.scrollEdgeAppearance = appearance
                    navigationBar.compactAppearance = appearance

                    navigationBar.tintColor = .white
                    
                }
                */

                // Enable large titles
                /*
                navigationController?.navigationBar.prefersLargeTitles = true
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                */
            }
            
            @objc func createChatButtonTapped() {
                //let userId1 = userId // Replace with actual user ID
                //let userId2 = hostId // Replace with actual user ID
                ChatManager.shared.createChat(userId1: userId ?? "", userId2: hostId ?? "") { result in
                    switch result {
                    case .success(let groupChannel):
                        DispatchQueue.main.async {
                            let channelVC = SBUGroupChannelViewController(channel: groupChannel)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                channelVC.navigationItem.rightBarButtonItem = nil
                                channelVC.navigationItem.rightBarButtonItems = []
                            }
                            self.navigationController?.pushViewController(channelVC, animated: true)
                        }
                    case .failure(let error):
                        print("Error creating chat: \(error.localizedDescription)")
                    }
                }
            }
            
            @objc func handleNewChannel(_ notification: Notification) {
                if let channel = notification.object as? GroupChannel {
                    channelManager.addChannel(channel)
                    //channelListVC.reloadChannelList()
                }
            }
            
        }
        
        
        // Create and return the custom view controller
        let customVC = CustomViewController(channelListVC: channelListVC, channelManager: channelManager, chatManager: ChatManager.shared)
        SBUGlobals.currentUser = SBUUser(userId: userId)
        
        let navController = UINavigationController(rootViewController: customVC)
        
        
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct userMessagesContainer: View {
    var userId: String
    @State private var channels: [GroupChannel] = []
    @State private var isLoading: Bool = false
    @Binding var unreadCount: Int

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading channels...")
            } else if channels.isEmpty {
                Spacer()
                VStack{
                    Image("nomore")
                        .resizable()
                        .frame(width:300,height:200)
                        .padding()
                    Text("No Chats Here")
                        .font(.custom("helvetica-bold", size: 20))
                        .foregroundColor(.black)
                }
            } else {
                List(channels, id: \.channelURL) { channel in
                    NavigationLink(destination: ChatView(channel: channel, userId: userId)) {
                        ChannelRow(channel: channel)
                    }
                }
            }
        }
        .onAppear {
            loadChannels()
        }
    }

    private func loadChannels() {
        isLoading = true
        
        let listQuery = GroupChannel.createMyGroupChannelListQuery { query in
            query.order = .latestLastMessage
            query.limit = 15
        }
        
        listQuery.loadNextPage { fetchedChannels, error in
            isLoading = false
            if let error = error {
                print("Error loading channels: \(error.localizedDescription)")
                return
            }
            self.channels = fetchedChannels ?? []
            self.unreadCount = fetchedChannels?.reduce(0, { (total: Int, channel: GroupChannel) -> Int in
                total + Int(channel.unreadMessageCount)
                }) ?? 0

        }
    }
}

struct ChannelRow: View {
    let channel: GroupChannel

    var body: some View {
        HStack {
            Text(channel.name)
            Spacer()
            Text(channel.lastMessage?.message ?? "No messages")
                .foregroundColor(.gray)
        }
    }
}

struct ChatView: View {
    let channel: GroupChannel
    let userId: String
    var body: some View {
        SendbirdChannelListView(userId: userId, channelManager: ChannelManager())
    }
}

struct userMessages: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if let currentUser = authService.userSession,
               let userId = UserDefaults.standard.string(forKey: "user_uuid") {
                SendbirdChannelListView(userId: userId, channelManager: ChannelManager())
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("No user logged in")
            }
        }
        .onAppear {
            fetchUser()
        }
    }

    private func fetchUser() {
        Task {
            if let userSession = authService.userSession,
               let userId = UserDefaults.standard.string(forKey: "user_uuid") {
                authService.fetchCurrentUser(for: userId)
            }
        }
    }
}

class ChatManager {
    static let shared = ChatManager()
    private init() {}
    func createChat(userId1: String, userId2: String, completion: @escaping (Result<GroupChannel, Error>) -> Void) {
        let params = GroupChannelCreateParams()
        //params.userIds = [userId1, ]
        params.addUserIds([userId1, userId2])
        params.name = "Chat"
        params.isDistinct = true
        GroupChannel.createChannel(params: params) { (groupChannel, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let groupChannel = groupChannel else {
                let error = NSError(domain: "ChatManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create group channel"])
                completion(.failure(error))
                return
            }
            completion(.success(groupChannel))
        }
    }
}




#Preview {
    userMessages()
        .environmentObject(AuthService.shared) // Provide the environment object
}









