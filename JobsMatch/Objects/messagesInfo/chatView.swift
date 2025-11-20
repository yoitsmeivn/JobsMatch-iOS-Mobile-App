//
//  chatView.swift
//  JobsMatch
//
//  Created by ivans Android on 3/25/24.
//
/*
import SwiftUI

struct chatView: View {
    @EnvironmentObject var viewModel: chatsviewmodel
    
    let chat: Chat
    
    @State private var text = ""
    @FocusState private var isFocused
    @State private var messageidtoscroll: UUID?
    
    var body: some View {
        VStack(spacing:0){
            GeometryReader{ reader in
                ScrollView{
                    ScrollViewReader{scrollReader in
                        getmessagesview(viewWidth: reader.size.width)
                            .padding(.horizontal)
                            .onChange(of: messageidtoscroll){
                                if let messageId = messageidtoscroll{
                                    scrollTo(messageId: messageId, shouldAnimate: true, scrollReader: scrollReader)
                                }
                            }
                            .onAppear{
                                if let messageId = chat.messages.last?.id{
                                    scrollTo(messageId: messageId,anchor:.bottom,shouldAnimate: false, scrollReader: scrollReader)
                                }
                                
                            }
                    }
                }
            }
            .padding(.bottom, 5)
            
            
            toolbarview()
        }
        .padding(.top,1)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: navbarleadingbtn)
        .onAppear{
            viewModel.markasUnread(false, chat: chat)
             
        }
        
        
    }
    
    var navbarleadingbtn: some View{
        Button(action:{}){
            HStack{
                Image(chat.person.imgstring)
                    .resizable()
                    .frame(width:40,height: 40)
                    .clipShape(Circle())
                Text(chat.person.name).bold()
            }
            .foregroundColor(.black)
        }
        
    }
    
    func scrollTo(messageId: UUID,anchor:UnitPoint? = nil, shouldAnimate:Bool,scrollReader:ScrollViewProxy){
        DispatchQueue.main.async{
            withAnimation(shouldAnimate ? Animation.easeIn : nil){
                scrollReader.scrollTo(messageId,anchor:anchor)
            }
        }
    }
    
    
    func toolbarview() -> some View{
        VStack{
            let height: CGFloat = 37
            HStack{
                TextField("Message ... ", text: $text)
                    .padding(.horizontal,10)
                    .frame(height:height)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .focused($isFocused)
                
                Button(action: sendmessage) {
                    Image(systemName:"paperplane.fill")
                        .foregroundColor(text.isEmpty ? .white: skyBlueColor.skyBlue)
                        .frame(width:height,height:height)
                        .background(
                            Circle()
                                .foregroundColor(.white)
                        )
                }
                .disabled(text.isEmpty)
            }
            .frame(height:height)
        }
        .padding(.vertical)
        .padding(.horizontal)
        .background(.thickMaterial)
        
    }
    
    func sendmessage(){
        if let message = viewModel.sendmessage(text,in:chat){
            text = ""
            messageidtoscroll = message.id
        }
        
    }
    
    let columns = [GridItem(.flexible(minimum: 10))]
    func getmessagesview(viewWidth: CGFloat) -> some View {
        LazyVGrid(columns: columns, spacing: 0, pinnedViews:[.sectionHeaders]){
            let sectionmessages = viewModel.getsectionmessage(for: chat)
            ForEach(sectionmessages.indices, id: \.self){ sectionIndex in
                let messages = sectionmessages[sectionIndex]
                Section(header: sectionheader(firstmessage: messages.first!)){
                    ForEach(messages){ message in
                        let isreceived = message.type == .Received
                        HStack{
                            ZStack{
                                Text(message.text)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                    .background(isreceived ? Color.black.opacity(0.2) : skyBlueColor.skyBlue.opacity(0.9))
                                    .cornerRadius(25)
                            }
                            .frame(width: viewWidth * 0.7,alignment: isreceived ? .leading: .trailing)
                            .padding(.vertical)
                        }
                        .frame(maxWidth: .infinity,alignment: isreceived ? .leading: .trailing)
                        .id(message.id)
                    }
                }
            }
        }
    }
    func sectionheader(firstmessage message:Message) -> some View{
        ZStack{
            Text(message.date.descriptiveString(dateStyle: .medium))
                .foregroundColor(.white)
                .font(.system(size:14,weight:.regular))
                .frame(width:120)
                .padding(.vertical,5)
                .background(Capsule().foregroundColor(skyBlueColor.skyBlue.opacity(0.7)))
        }
        .padding(.vertical,5)
        .frame(maxWidth:.infinity)
        
    }
    
    
    
}

struct chatview_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView{
            chatView(chat: Chat.sampleChat[0])
                .environmentObject(chatsviewmodel())
        }
    }
}*/
