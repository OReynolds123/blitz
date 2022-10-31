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
                    initHelper(initView: self.$initView)
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
    @Binding var initView: Bool
    
    var body: some View {
        VStack {
            Text("Start Studying")
                .font(.title)
            
            Divider().frame(width: 100)
            
            VStack(alignment: .leading) {
                Text("Welcome to Blitz where studying using flashcards becomes much quicker and simpler with the Blitz app.")
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Home")
                        .font(.headline)
                    Text("Start here by clicking Create deck under home or in the deck selection")
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Deck Title and Templete")
                        .font(.headline)
                    Text("Here you can give a Deck Title, customize your decks Card Color, Text Color, and Font Type that will apply to all of your cards")
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Front and Back of card Editing mode")
                        .font(.headline)
                    Text("Edit and use the text API feature where you can upload any photo or document and translate it into editable text")
                }
            }
            
            Button(action: {
                self.initView = false
            }, label: {
                Text("Let's Begin")
            })
            .buttonStyle(DefaultButtonStyle())
        }
        .padding()
    }
}

struct blitzApp_Previews: PreviewProvider {
    static var previews: some View {
        initHelper(initView: .constant(false))
    }
}
