//
//  blitzApp.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI

@main
struct blitzApp: App {
    @StateObject private var userDataStore = userStore()
    
    @State private var creationView = false
    @State private var testView = false
    @State private var fullView = false
    @State private var quizView = false
    @State private var initView = false
    
    var body: some Scene {
        WindowGroup {
            blitzHomeView(creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView, initView: self.$initView)
                .sheet(isPresented: self.$initView) {
                    initHelper(initView: self.$initView, creationView: self.$creationView)
                }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("New Deck") {
                    self.userDataStore.userData.append(deck: deck())
                    self.userDataStore.userData.changeIndex(index: self.userDataStore.userData.decks.count - 1)
                    userStore.save(user: self.userDataStore.userData) { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let uuid):
                            print(uuid)
                        }
                    }
                    self.creationView = true
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Blitz Help") {
                    self.initView.toggle()
                }
            }
        } // commands
        .onChange(of: self.fullView) { _bind in
            load()
        }
        .onChange(of: self.creationView) { _bind in
            load()
        }
        .onChange(of: self.testView) { _bind in
            load()
        }
        .onChange(of: self.quizView) { _bind in
            load()
        }
    } //body
    
    private func load() {
        userStore.load { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let userData):
                self.userDataStore.userData = userData
            }
        }
    }
}

struct initHelper: View {
    @StateObject private var userDataStore = userStore()
    
    @Binding var initView: Bool
    @Binding var creationView: Bool
    
    private let txtArr: [textArr] = [
        textArr(title: "Home", desc:"The main home page where you can see all of your study decks. Press on a deck to study it or right click to quickly go to a certain study mode."),
        textArr(title: "Creation/Edit Mode", desc: "Here you can give a deck title and create cards for studying. Use the Photo-To-Text feature (camera icon on the top right of the card) to quickly add text from your photos!"),
        textArr(title: "Flashcard Mode", desc: "This mode lets you see the front and back of all of your cards."),
        textArr(title: "Test Mode", desc: "This mode lets you test yourself. Simply click the card to see the other side and swipe left or right to see the next card. By swipping left, the card will be flagged as correct and will disappear from the deck, and swipping right will flag the card as incorrect and will reappear in the deck. Use the 'Flip Cards' button (bottom of the navigation bar on the left) to flip all of the cards and study the other side."),
        textArr(title: "Quiz Mode", desc: "This mode lets you quiz yourself. Type the opposite side of the card in the input box and press enter to check yourself. The card will light up green or red depending if you are correct or not. Like Test mode, click the card to see the other side and swipe left or right to see the next card. By swipping left, the card will be flagged as correct and will disappear from the deck, and swipping right will flag the card as incorrect and will reappear in the deck. Use the 'Flip Cards' button (bottom of the navigation bar on the left) to flip all of the cards and study the other side.")
    ]
    
    var body: some View {
        VStack {
            Image("AppIcon")
                .resizable()
                .frame(width: 150, height: 150)
            
//            Text("Start Studying")
//                .font(.title)
//
//            Divider().frame(width: 100)
            
            VStack(alignment: .leading) {
                Text("Welcome to Blitz where studying using flashcards becomes much quicker and simpler.")
                
                Spacer()
                
                ForEach(self.txtArr) { elem in
                    VStack(alignment: .leading) {
                        Text(elem.title)
                            .font(.headline)
                        
                        Text(elem.desc)
                    }
                    Spacer()
                }
            }
            
            Button(action: {
                self.initView = false
                if self.userDataStore.userData.decks.count > 0 {
                    if self.userDataStore.userData.decks[0].title == "Tutorial Deck" {
                        self.userDataStore.userData.changeIndex(index: 0)
                        userStore.save(user: self.userDataStore.userData) { result in
                            switch result {
                            case .failure(let error):
                                fatalError(error.localizedDescription)
                            case .success(let uuid):
                                print(uuid)
                            }
                        }
                        self.creationView = true
                    }
                }
                
            }, label: {
                Text("Let's Begin")
            })
            .buttonStyle(DefaultButtonStyle())
        }
        .padding()
        .frame(idealWidth: 600)
        .onAppear {
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                }
            }
        }
    } // body
    
    private struct textArr: Identifiable {
        let title: String
        let desc: String
        var id: String { title }
    }
}
