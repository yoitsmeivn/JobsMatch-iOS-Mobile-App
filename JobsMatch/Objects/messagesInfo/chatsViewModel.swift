import Foundation
/*
class chatsviewmodel: ObservableObject {
    @Published var chats = Chat.sampleChat

    func getsortedfileteredchats(query: String) -> [Chat] {
        let sortedchats = chats.sorted {
            guard let date1 = $0.messages.last?.date else { return false }
            guard let date2 = $1.messages.last?.date else { return false }
            return date1 > date2
        }
        if query == "" {
            return sortedchats
        }
        return sortedchats.filter { $0.person.name.lowercased().contains(query.lowercased()) }
    }

    func getsectionmessage(for chat: Chat) -> [[Message]] {
        var res = [[Message]]()
        var tmp = [Message]()
        for message in chat.messages {
            if let firstmessage = tmp.first {
                let daysBetween = firstmessage.date.daysBetween(date: message.date)
                if daysBetween >= 1 {
                    res.append(tmp)
                    tmp.removeAll()
                    tmp.append(message)
                } else {
                    tmp.append(message)
                }
            } else {
                tmp.append(message)
            }
        }
        res.append(tmp)
        return res
    }

    func markasUnread(_ newValue: Bool, chat: Chat) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index].hasunreadmessage = newValue
        }
    }

    func sendmessage(_ text: String, in chat: Chat) -> Message? {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            let message = Message(text, type: .Sent)
            chats[index].messages.append(message)
            return message
        }
        return nil
    }

    func createNewChat(with user: User) -> Chat {
        let newChat = Chat(
            person: Person(name: "\(user.firstName) \(user.lastName)", imgstring: user.resume),
            messages: [
                Message("Welcome to the new chat with \(user.firstName)!", type: .Received, date: Date())
            ],
            hasunreadmessage: false
        )
        chats.append(newChat)
        return newChat
    }
} */
