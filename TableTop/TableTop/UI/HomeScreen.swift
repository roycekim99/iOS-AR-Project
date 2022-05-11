//
//  HomeScreen.swift
//  TableTop
//
//  Created by Ashley Li on 5/10/22.
//

import SwiftUI
import Combine

// MARK: UserNameView: first homescreen asks for username
struct UserNameView: View {
    let limit = 10
    @Binding var userName: String
    @Binding var showStartView: Bool
    @Binding var showUsernameView: Bool

    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .frame(width: 400, height: 400)

            Text("Please create a username before starting the game")
                .padding(10)
                .foregroundColor(.white)

            Text("Limited to 10 characters")
                .padding(5)
                .foregroundColor(.white)

            HStack{
                TextField("Username", text: $userName)
                    .onReceive(Just(userName)){
                        _ in limitText(limit)
                    }
                    .multilineTextAlignment(.center)
            }
            .textFieldStyle(CustomInputBox())

            Buttons(text: "Next", fontStyle: "title2") {

                if self.userName.count > 0 {
                    ModelLibrary.username = self.userName
                    self.showUsernameView.toggle()
                    self.showStartView.toggle()
                }

            }
            .padding(30)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    func limitText(_ limit: Int) {
        if userName.count > limit {
            userName = String(userName.prefix(limit))
        }
    }

}

// MARK: Second homescreen -- show game menu
struct StartView: View {
    @Binding var showStartView: Bool
    @Binding var showUsernameView: Bool
    @State private var showAbout = false
    @State private var showJoin = false
    @State private var showHowTo = false

    var body: some View {
        VStack {
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 250, height: 250)
            }
            
            VStack {
                Text("Welcome, \(ModelLibrary.username)")
                    .bold()
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
            }
            .padding(.bottom, 80)
            
            VStack(spacing: 30){
                // button for starting the game
                Buttons(text: "Start Game", fontStyle: "title"){
                    self.showStartView.toggle()
                }
                
                // button for instructions
                Buttons(text: "How to Play", fontStyle: "title" ){
                    self.showHowTo.toggle()
                }
                .sheet(isPresented: $showHowTo){
                    HowToView(showHowto: $showHowTo)
                }
        
                //button for joining a game
                Buttons(text: "Join a Game", fontStyle: "title" ){
                    self.showJoin.toggle()
                }
                .sheet(isPresented: $showJoin){
                    JoinView(showJoin: $showJoin, showStartView: $showStartView)
                }
                
                // button for about
                Buttons(text: "About", fontStyle: "title"){
                    self.showAbout.toggle()
                    
                }
                .sheet(isPresented: $showAbout){
                    AboutView(showAbout: $showAbout)
                }
                
                Buttons(text: "Back", fontStyle: "title"){
                    self.showStartView.toggle()
                    self.showUsernameView.toggle()
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .padding(.bottom, 100)
        .background(Color.black)
    }

}

// MARK: how to play view
struct HowToView: View {
    @Binding var showHowto: Bool
    let instructions = Instruction.instructionSet
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(0..<3) {i in
                        cardView(showHowto: $showHowto,title: instructions[i].title, text: instructions[i].body)
                            .padding(10)
                    }
                }
                
            }
            Buttons(text: "Done", fontStyle: "title2"){
                self.showHowto.toggle()
            }
        }
       
    }
}

struct Instruction {
    var title: String
    var body: String
    
    static let instructionSet: [Instruction] =
    [
        Instruction(title: "Starting The Game", body: "Select the play area of the game with the displayed grid. Tap on the checkmark when play area is chosen."),
        Instruction(title: "Placing Models", body: "Tap the browse menu on the bottom of the screen to display the available models. After choosing a model to place, a grid will be displayed. Click the checkmark to place the model in the location of the grid. Clicking the cancel button will return you to the game."),
        Instruction(title: "Deleting Models", body: "Tap the trash icon in the top corner to initiate model deletion. Tapping on a model will highlight it and select it for deletion. Click the trash icon to confirm deletion. Furthermore, tapping the \"Delete All\" button will remove all models from the scene. Tapping the cancel button will cancel deletiona and return to the game")
    ]
}

struct cardView: View {
    @Binding var showHowto: Bool
    let title: String
    let text: String

    var body: some View {
        VStack {
            Text(title).bold()
            
            Text(text)
                .padding(.top, 40)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(width: 400, height: 600)
//        .background(Color.red)

    }
}

// MARK: about view
struct AboutView: View {
    @Binding var showAbout: Bool
//    @Binding var showStartView: Bool
    
    var body: some View {
        VStack{
            VStack {
                Text("this is the about page")
            }
            .frame(width: 400, height: 600)
            
            Buttons(text: "Back", fontStyle:"title2" ){
                self.showAbout.toggle()
            }
        }
    }
}

// MARK: Join a game
struct JoinView: View {
    @Binding var showJoin: Bool
    @Binding var showStartView: Bool
    @State var sessionID = ""
    let limit = 10
    
    var body: some View {

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
                self.showStartView.toggle()
            }
            .padding(.top, 10)
            .padding(10)
            
            Buttons(text: "cancel", fontStyle:"title2" ){
                self.showJoin.toggle()
            }
            .padding(10)
            
            
        }

        
}
    
    func limitText(_ limit: Int) {
        if sessionID.count > limit {
            sessionID = String(sessionID.prefix(limit))
        }
    }
    
}

struct CustomInputBox: TextFieldStyle {

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(width: UIScreen.main.bounds.width * 0.8, height:UIScreen.main.bounds.height * 0.05 )
            .padding(5)
            .font(.custom("Open Scans", size: 20))
            .foregroundColor(.white)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(9)
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
        .frame(width: UIScreen.main.bounds.width * 0.8 , height: UIScreen.main.bounds.width * 0.1)
        .background(Color.white)
        .cornerRadius(9)

    }
}

