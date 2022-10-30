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
    
    var body: some Scene {
        WindowGroup {
            blitzHomeView(creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView)
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
