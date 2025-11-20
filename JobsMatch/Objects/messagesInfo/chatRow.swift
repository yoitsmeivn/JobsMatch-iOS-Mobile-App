
import SwiftUI

struct chatrow: View {
    let chat:Chat
    
    var body: some View {
        HStack(spacing:20){
            Image(chat.person.imgstring)
                .resizable()
                .frame(width:70,height:70)
                .clipShape(Circle())
            
            ZStack{
                VStack(alignment: .leading, spacing:5){
                    HStack{
                        Text(chat.person.name)
                            .bold()
                        Spacer()
                        Text(chat.messages.last?.date.descriptiveString() ?? "")
                        
                        
                        
                    }
                    HStack{
                        Text(chat.messages.last?.text ?? "")
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .frame(height:50,alignment:.top)
                            .frame(maxWidth:.infinity,alignment:.leading)
                            .padding(.trailing,40)
                        
                        
                    }
                }
                Circle()
                    .foregroundColor(chat.hasunreadmessage ? skyBlueColor.skyBlue : .clear)
                    .frame(width:13,height:13)
                    .frame(maxWidth:.infinity,alignment:.trailing)
            }
        }
        .frame(height:80)
        

    }
}

struct chatrow_Previews: PreviewProvider {
    static var previews: some View {
        chatrow(chat:Chat.sampleChat[0])
    }
}
