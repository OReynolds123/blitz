//
//  blitzApp.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22. 
//

import SwiftUI

@main
struct blitzApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var userDataStore = userStore()
    @StateObject private var viewManager = viewsManager()

    var body: some Scene {
        WindowGroup {
            blitzHomeView(userDataStore: self.userDataStore, viewManager: self.viewManager)
                .sheet(isPresented: self.$viewManager.views.initView) {
                    initHelper(userDataStore: self.userDataStore, viewManager: self.viewManager)
                }
                .sheet(isPresented: self.$viewManager.views.settingsView) {
                    settingView(userDataStore: self.userDataStore, viewManager: self.viewManager)
                }
                .alert(isPresented: self.$viewManager.views.deleteAlert) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("Are you sure you would like to delete this deck?"),
                        primaryButton: .destructive(
                            Text("Yes"),
                            action: {
                                self.userDataStore.userData.decks.remove(at: self.userDataStore.userData.deckIndex)
                                self.saveUserData()
                            }
                        ),
                        secondaryButton: .default(
                            Text("No"),
                            action: { }
                        )
                    )
                }
                .onAppear {
                    userStore.load { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let userData):
                            self.userDataStore.userData = userData
                            if self.userDataStore.userData.initialLaunch {
                                self.viewManager.views.initView = true
                                self.userDataStore.userData.initialLaunch = false
                                self.saveUserData()
                            }
                        }
                    }
                }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                Button("Preferences") {
                    if (self.viewManager.views.settingsView) {
                        self.viewManager.views.hideAll()
                    } else {
                        self.viewManager.views.hideAll()
                        self.viewManager.views.settingsView = true
                    }
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("New Deck") {
                    self.viewManager.views.hideAll()
                    self.userDataStore.userData.append(deck: deck())
                    self.userDataStore.userData.changeIndex(index: self.userDataStore.userData.decks.count - 1)
                    self.saveUserData()
                    self.viewManager.views.creationView = true
                }
                Button("Edit Deck") {
                    self.viewManager.views.hideAll()
                    self.saveUserData()
                    self.viewManager.views.creationView = true
                }.disabled(!self.viewManager.views.inDeckViews())
            }
            CommandGroup(replacing: CommandGroupPlacement.saveItem) {
                Button("Close Deck") {
                    self.viewManager.views.hideAll()
                    self.saveUserData()
                }.disabled(!self.viewManager.views.inDeckViews())
            }
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("blitz Help") {
                    if (self.viewManager.views.initView) {
                        self.viewManager.views.hideAll()
                    } else {
                        self.viewManager.views.hideAll()
                        self.viewManager.views.initView = true
                    }
                }
            }
        } // commands
    } //body
    
    func saveUserData() {
        userStore.save(user: self.userDataStore.userData) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let uuid):
                print(uuid)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

struct appViews: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var creationView = false
    var testView = false
    var fullView = false
    var quizView = false
    var initView = false
    var settingsView = false
    var homeHelp = false
    var deleteAlert = false
    var helpAlert = false
    var settingsAlert = false
    
    mutating func hideAll() {
        self.creationView = false
        self.testView = false
        self.fullView = false
        self.quizView = false
        self.initView = false
        self.settingsView = false
        self.homeHelp = false
        self.deleteAlert = false
        self.helpAlert = false
        self.settingsAlert = false
    }
    
    func inDeckViews() -> Bool {
        return (self.creationView || self.testView || self.fullView || self.quizView)
    }
}
class viewsManager: ObservableObject {
    @Published var views: appViews = appViews()
}

struct settingView: View {
    @StateObject var userDataStore: userStore
    @StateObject var viewManager: viewsManager
    
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
                    self.viewManager.views.settingsAlert = true
                }, label: {
                    Text("Reset all user data")
                })
                .buttonStyle(DefaultButtonStyle())
                .foregroundColor(Color(NSColor.systemRed))
                .alert(isPresented: self.$viewManager.views.settingsAlert) {
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
                                        self.viewManager.views.settingsView = false
                                        self.viewManager.views.initView = true
                                        self.userDataStore.userData.initialLaunch = false
                                    }
                                }
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
                    self.viewManager.views.settingsView = false
                }, label: {
                    Text("Close")
                })
                .buttonStyle(DefaultButtonStyle())
            }
            .offset(x: 0, y: -10)
        }
        .frame(width: 250, height: 200)
    } // body
}

struct initHelper: View {
    @StateObject var userDataStore: userStore
    @StateObject var viewManager: viewsManager
    
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
                self.viewManager.views.initView = false
                if self.userDataStore.userData.decks.count > 0 {
                    if self.userDataStore.userData.decks[0].title == "Tutorial Deck" {
                        self.userDataStore.userData.changeIndex(index: 0)
                        self.viewManager.views.creationView = true
                    }
                }
            }, label: {
                Text("Let's Begin")
            })
            .buttonStyle(DefaultButtonStyle())
        }
        .padding()
        .frame(idealWidth: 600)
    } // body
    
    private struct textArr: Identifiable {
        let title: String
        let desc: String
        var id: String { title }
    }
}

// Custom ForEach with Binding
struct ForEachIndexed<Data: MutableCollection&RandomAccessCollection, RowContent: View, ID: Hashable>: View, DynamicViewContent where Data.Index : Hashable
{
    var data: [(Data.Index, Data.Element)] {
        forEach.data
    }
    
    let forEach: ForEach<[(Data.Index, Data.Element)], ID, RowContent>
    
    init(_ data: Binding<Data>,
         @ViewBuilder rowContent: @escaping (Data.Index, Binding<Data.Element>) -> RowContent
    ) where Data.Element: Identifiable, Data.Element.ID == ID {
        forEach = ForEach(
            Array(zip(data.wrappedValue.indices, data.wrappedValue)),
            id: \.1.id
        ) { i, _ in
            rowContent(i, Binding(get: { data.wrappedValue[i] }, set: { data.wrappedValue[i] = $0 }))
        }
    }
    
    init(_ data: Binding<Data>,
         id: KeyPath<Data.Element, ID>,
         @ViewBuilder rowContent: @escaping (Data.Index, Binding<Data.Element>) -> RowContent
    ) {
        forEach = ForEach(
            Array(zip(data.wrappedValue.indices, data.wrappedValue)),
            id: (\.1 as KeyPath<(Data.Index, Data.Element), Data.Element>).appending(path: id)
        ) { i, _ in
            rowContent(i, Binding(get: { data.wrappedValue[i] }, set: { data.wrappedValue[i] = $0 }))
        }
    }
    
    var body: some View {
        forEach
    }
}
