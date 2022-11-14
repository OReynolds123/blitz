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
    @State private var settingsView = false
    
    var body: some Scene {
        WindowGroup {
            blitzHomeView(creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView, initView: self.$initView, settingsView: self.$settingsView)
                .sheet(isPresented: self.$initView) {
                    initHelper(initView: self.$initView, creationView: self.$creationView)
                }
                .sheet(isPresented: self.$settingsView) {
                    settingView(settingsView: self.$settingsView)
                }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                Button("Preferences") {
                    self.settingsView.toggle()
                }
            }
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
        .onChange(of: self.settingsView) { _bind in
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

struct settingView: View {
    @StateObject private var userDataStore = userStore()
    
    @Binding var settingsView: Bool
    
    @State private var alert: Bool = false
    
    var body: some View {
        VStack {
            Image("ico")
                .resizable()
                .frame(width: 100, height: 100)
            
            VStack {
                Text("Settings")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    self.alert = true
                }, label: {
                    Text("Reset all user data")
                })
                .buttonStyle(DefaultButtonStyle())
                .foregroundColor(Color(NSColor.systemRed))
                .alert(isPresented: self.$alert) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("This action cannot be undone!"),
                        primaryButton: .destructive(
                            Text("Yes"),
                            action: {
                                self.userDataStore.userData = user()
                                userStore.save(user: self.userDataStore.userData) { result in
                                    switch result {
                                    case .failure(let error):
                                        fatalError(error.localizedDescription)
                                    case .success(let uuid):
                                        print(uuid)
                                    }
                                }
                                self.settingsView = false
                            }
                        ),
                        secondaryButton: .default(
                            Text("No"),
                            action: { }
                        )
                    )
                }
                
                Spacer()
                
                Button(action: {
                    self.settingsView = false
                }, label: {
                    Text("Close")
                })
                .buttonStyle(DefaultButtonStyle())
            }
            .offset(x: 0, y: -10)
        }
        .frame(width: 250, height: 200)
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
}

struct initHelper: View {
    @StateObject private var userDataStore = userStore()
    
    @Binding var initView: Bool
    @Binding var creationView: Bool
    
    private let txtArr: [textArr] = [
        textArr(title: "Home", desc:"The Home view contains all study decks. Press on a deck to study it or right click for more options."),
        textArr(title: "Creation/Edit Mode", desc: "The Edit mode allows you to quickly create flashcards. Use the Photo-To-Text feature (camera icon on the top right of the card) to quickly add text from your photos!"),
        textArr(title: "Flashcard Mode", desc: "The Flashcard mode allows users to view all of the information within a deck at once."),
        textArr(title: "Test Mode", desc: "The Test mode allows you to test yourself. Simply click the card to see the other side and swipe to see the next card. Swiping right will flag the card as correct and it will disappear from the deck. Swiping left will flag the card as incorrect and it will remain in the deck."),
        textArr(title: "Quiz Mode", desc: "The Quiz mode allows you to quiz yourself. Type the opposite side of the card in the input box and press enter to check yourself. The card will light up green or red depending if you are correct or not.")
    ]
    
    var body: some View {
        VStack {
            Image("ico")
                .resizable()
                .frame(width: 150, height: 150)
            
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
