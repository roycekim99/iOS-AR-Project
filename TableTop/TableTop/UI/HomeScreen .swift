//
//  HomeScreen .swift
//  TableTop
//
//  Created by Ashley Li on 5/6/22.
//

import SwiftUI
import Combine

struct HomeScreen: View {
    @State var userName = ""
//    @Binding var showStartView: Bool
    @State private var showStartView = false
    @Binding var showHomeView: Bool
    
    let limit = 15

    var body: some View {
        VStack {
            Text("LOGO")
                .padding(100)
            
            Text("Please create a username before starting the game")
                .padding(10)
            
            Text("Limited 15 characters")
            
            HStack{
                TextField("Username", text: $userName)
                    .onReceive(Just(userName)){
                        _ in limitText(limit)
                    }
            }
            .textFieldStyle(CustomInputBox())
            
            Buttons(text: "Next", fontStyle: "title2") {
                // action: store the username somewhere by calling the setfunction
                
                ModelLibrary.username = self.userName
                self.showStartView.toggle()
                
            }.fullScreenCover (isPresented: $showStartView){
                StartView(showStartView: $showStartView, showHomeView: $showHomeView)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        
    }

    func limitText(_ limit: Int) {
        if userName.count > limit {
            userName = String(userName.prefix(limit))
        }
    }
}

struct CustomInputBox: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(width: 500, height: 60)
            .font(.custom("Open Scans", size: 20))
            .background(Color.gray.opacity(0.5))
            .cornerRadius(9)
            .padding(.bottom, 70)
    }
}

struct StartView: View {
    @Binding var showStartView: Bool
//    @State private var showArView = false
    @Binding var showHomeView: Bool
    @State private var showAbout = false
    @State private var showJoin = false
    @State private var showHowTo = false

    var body: some View {
        NavigationView {
            VStack(spacing: 200) {
                Text("Welcome, \(ModelLibrary.username)")
                    .bold()
                    .font(.system(size: 40))

                VStack(spacing: 30){
                    // button for starting the game
                    Buttons(text: "Start Game", fontStyle: "title"){
                        self.showHomeView.toggle()
                    }
                    .background(Color.black)

                    // button for instructions
                    Buttons(text: "How to Play", fontStyle: "title" ){
                        self.showHowTo.toggle()
                    }
                    .sheet(isPresented: $showHowTo){
                        HowToView(showHowto: $showHowTo)
                    }
                    .background(Color.black)

                    //button for joining a game
                    Buttons(text: "Join a Game", fontStyle: "title" ){
                        self.showJoin.toggle()
                    }
                    .sheet(isPresented: $showJoin){
                        JoinView(showJoin: $showJoin)
                    }
                    .background(Color.black)

                    // button for about
                    Buttons(text: "About", fontStyle: "title"){
                        self.showAbout.toggle()

                    }
                    .sheet(isPresented: $showAbout){
                        AboutView(showAbout: $showAbout)
                    }
                    .background(Color.black)
                }



            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.8))
            .navigationBarItems(leading:
                Button(action: {
                self.showStartView.toggle()
            }){
                Text("back").bold()
            }
            )
        }
    }

}

struct HowToView: View {
    @Binding var showHowto: Bool
    var body: some View {
        VStack {
            Buttons(text: "Done", fontStyle: "title2"){
                self.showHowto.toggle()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(0..<4) {i in
                        cardView(showHowto: $showHowto, text: "instruction \(i)")
                            .padding(10)
                    }
                }
//                .background(Color.red)
            }
//            .frame(width: 400, height: 600)
        }
    }
}

struct cardView: View {
    @Binding var showHowto: Bool
    let text: String

    var body: some View {
        VStack {
            Text(text)
        }
        .frame(width: 400, height: 600)
        .background(Color.red)

    }
}

struct AboutView: View {
    @Binding var showAbout: Bool
//    @Binding var showStartView: Bool
    
    var body: some View {
        
//        NavigationView {
            VStack{
                Buttons(text: "Back", fontStyle:"title2" ){
                    self.showAbout.toggle()
                }
                Text("this is the about page")
            }

//        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .navigationTitle("About")
        .navigationBarItems(leading:
            Button(action: {
            self.showAbout.toggle()
        }){
            Text("back").bold()
        }
        )

    }
}

struct JoinView: View {
    @Binding var showJoin: Bool
    @State var sessionID = ""
    let limit = 10
    
    var body: some View {
//        NavigationView {
            VStack {
                Text("Enter the session ID you want to join")
                    .padding()
                
                HStack{
                    TextField("Session ID", text: $sessionID)
                        .onReceive(Just(sessionID)){
                            _ in limitText(limit)
                        }
                }
                .textFieldStyle(CustomInputBox())
                
                Buttons(text: "Join", fontStyle: "title2"){
                    // start arview
                }
                
                Buttons(text: "cancel", fontStyle:"title2" ){
                    self.showJoin.toggle()
                }
                
                
            }
//        }
        
}
    
    func limitText(_ limit: Int) {
        if sessionID.count > limit {
            sessionID = String(sessionID.prefix(limit))
        }
    }
    
}


struct Buttons: View {

    let text: String

    let fontStyle: String

    let action: () -> Void

    var body: some View {
        Button {
            self.action()
        } label: {
            switch fontStyle {
            case "title":
                Text(text)
                    .font(.title)
            case "title2":
                Text(text)
                    .font(.title2)
            default:
                Text(text)
            }

        }
        .frame(width: 300, height: 30)
        .padding(30)

    }
}
