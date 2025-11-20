
import Foundation
struct Chat:Identifiable{
    var id: UUID {person.id}
    let person:Person
    var messages: [Message]
    var hasunreadmessage=false
    
}
struct Person:Identifiable{
    let id=UUID()
    let name:String
    let imgstring:String
}

struct Message:Identifiable{
    enum MessageType{
        case Sent,Received
            
    }
    
    let id = UUID()
    let date: Date
    let text:String
    let type: MessageType
    
    init(_ text:String,type:MessageType,date:Date){
        self.date=date
        self.type=type
        self.text=text
    }
    init(_ text:String,type:MessageType){
        self.init(text,type:type,date:Date())
    }
}

extension Chat{
    static let sampleChat=[
        Chat(person: Person(name:"Jobs Match",imgstring:"JobsMatchLogo"),messages:[
            Message("Hey Hakim",type:.Sent,date:Date(timeIntervalSinceNow:-86400*3)),
            Message("OMG WSP",type:.Received,date:Date(timeIntervalSinceNow:-86400*2)),
            Message("HOW Life",type:.Received,date:Date(timeIntervalSinceNow:-86400*2)),
            Message("Congratulations!",type:.Sent,date:Date(timeIntervalSinceNow:-86400*1)),
         ],hasunreadmessage: true),
        
        Chat(person: Person(name:"Jobs Match",imgstring:"JobsMatchLogo"),messages:[
            Message("Hey vadim",type:.Sent,date:Date(timeIntervalSinceNow:-86400*5)),
            Message("playing a game rn",type:.Received,date:Date(timeIntervalSinceNow:-86400*2)),
            Message("can call later",type:.Received,date:Date(timeIntervalSinceNow:-86400*3)),
            Message("sure when at?",type:.Sent,date:Date(timeIntervalSinceNow:-86400*1)),
        ]),
    ]
    
}
