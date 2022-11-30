//
//  blitzHomeView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/24/22.
//

import SwiftUI

struct blitzHomeView: View {
    @StateObject var userDataStore: userStore
    @StateObject var viewManager: viewsManager
    
    var width: CGFloat = 200
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack {
                    Button(action: {
                        
                    }, label: {
                        Image("ico")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .padding(.top, -10)
                            .padding(.bottom, -10)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .help("Home")
                    
                    Divider().padding(.horizontal, 20)
                    
                    List {
                        ForEachIndexed(self.$userDataStore.userData.decks) { index, elem in
                            Button(action: {
                                self.userDataStore.userData.changeIndex(index: index)
                                self.viewManager.views.fullView = true
                            }, label: {
                                Text(elem.wrappedValue.title == "" ? "Deck \(index + 1)" : elem.wrappedValue.title)
                                    .foregroundColor(Color("nav_titleColor"))
                            })
                            .contextMenu {
                                Button("View Full Deck") {
                                    self.userDataStore.userData.changeIndex(index: index)
                                    self.viewManager.views.fullView = true
                                }
                                Button("Test Yourself") {
                                    self.userDataStore.userData.changeIndex(index: index)
                                    self.viewManager.views.testView = true
                                }
                                Button("Quiz Yourself") {
                                    self.userDataStore.userData.changeIndex(index: index)
                                    self.viewManager.views.quizView = true
                                }
                                Button("Edit Deck") {
                                    self.userDataStore.userData.changeIndex(index: index)
                                    self.viewManager.views.creationView = true
                                }
                                Button("Delete Deck") {
                                    self.userDataStore.userData.changeIndex(index: index)
                                    self.viewManager.views.deleteAlert = true
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Quiz Yourself")
                        }
                        
                        Button(action: {
                            createDeck()
                        }, label: {
                            Text("New Deck")
                                .foregroundColor(Color("nav_altColor"))
                        })
                        .contextMenu {
                            Button("New Deck") {
                                createDeck()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Add Deck")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                } // VStack

                ScrollView(.vertical) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:self.width), spacing: 10, alignment: .leading)]) {
                        addDeck(width: self.width)
                            .onTapGesture {
                                createDeck()
                            }
                            .contextMenu {
                                Button("New Deck") {
                                    createDeck()
                                }
                            }
                        
                        ForEachIndexed(self.$userDataStore.userData.decks) { index, elem in
                            cardStack(title: elem.title.wrappedValue, width: self.width)
                                .onTapGesture {
                                    self.userDataStore.userData.changeIndex(index: index)
                                    self.viewManager.views.fullView = true
                                }
                                .contextMenu {
                                    Button("View Deck") {
                                        self.userDataStore.userData.changeIndex(index: index)
                                        self.viewManager.views.fullView = true
                                    }
                                    Button("Test Yourself") {
                                        self.userDataStore.userData.changeIndex(index: index)
                                        self.viewManager.views.testView = true
                                    }
                                    Button("Quiz Yourself") {
                                        self.userDataStore.userData.changeIndex(index: index)
                                        self.viewManager.views.quizView = true
                                    }
                                    Button("Edit Deck") {
                                        self.userDataStore.userData.changeIndex(index: index)
                                        self.viewManager.views.creationView = true
                                    }
                                    Button("Delete Deck") {
                                        self.userDataStore.userData.changeIndex(index: index)
                                        self.viewManager.views.deleteAlert = true
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Blitz")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: {
                            toggleSidebar()
                        }, label: {
                            Image(systemName: "sidebar.left")
                        })
                        .help("Toggle Sidebar")
                    }
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            self.viewManager.views.homeHelp.toggle()
                        }, label: {
                            Label("Help", systemImage: "questionmark")
                        })
                        .alert(isPresented: self.$viewManager.views.homeHelp) {
                            Alert(
                                title: Text("Blitz Help"),
                                message: Text("Use the navigation bar on the left or press the decks on the right to begin studying!\n\n(By right clicking you can quickly go to a certain study mode)")
                            )
                        }
                        .help("Help")
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            createDeck()
                        }, label: {
                            Label("New Deck", systemImage: "plus")
                        })
                        .help("Add Deck")
                    }
                }
                .sheet(isPresented: self.$viewManager.views.creationView) {
                    deckCreation(userDataStore: self.userDataStore, viewManager: self.viewManager)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
                .sheet(isPresented: self.$viewManager.views.testView) {
                    deckTestView(userDataStore: self.userDataStore, viewManager: self.viewManager)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
                .sheet(isPresented: self.$viewManager.views.fullView) {
                    deckFullView(userDataStore: self.userDataStore, viewManager: self.viewManager)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
                .sheet(isPresented: self.$viewManager.views.quizView) {
                    deckQuizView(userDataStore: self.userDataStore, viewManager: self.viewManager)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
            } // nav
        } // geo
        .touchBar() {
            Button(action: {
                createDeck()
            }, label: {
                Label("New Deck", systemImage: "plus")
            })
            
            ForEachIndexed(self.$userDataStore.userData.decks) { index, elem in
                Button(elem.wrappedValue.title, action: {
                    self.userDataStore.userData.changeIndex(index: index)
                    self.viewManager.views.fullView = true
                })
            }
        }
        .frame(minWidth: 800, minHeight: 500)
    } // body
    
    private func createDeck() {
        self.userDataStore.userData.append(deck: deck())
        self.userDataStore.userData.changeIndex(index: self.userDataStore.userData.decks.count - 1)
        self.viewManager.views.creationView = true
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?
            .contentViewController?
            .tryToPerform(
                #selector(NSSplitViewController.toggleSidebar(_:)),
                with: nil
            )
    }
}

struct blitzHomeView_Previews: PreviewProvider {
    static var previews: some View {
        blitzHomeView(userDataStore: userStore(), viewManager: viewsManager())
    }
}


// Add Deck View
struct addDeck: View {
    var width: CGFloat = 450
    
    @State private var hover: Bool = false
    
    var body: some View {
        ZStack {
            let elem = AnyView(
                Image(systemName: "plus")
                    .resizable()
                    .padding(25)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("shamrock"))
                    .frame(width: self.width - 100, height: self.width - 100)
            )
            cardStruct(elem: elem, width: self.width)
                .onHover { hover in
                    self.hover = hover
                }
                .offset(x: 0, y: self.hover ? -2 : 0)
                .scaleEffect(self.hover ? 1.01 : 1)
                .animation(.interpolatingSpring(stiffness: 180, damping: 100))
        }
        .help("Add Deck")
    }
}

// Card Stack View
struct cardStack: View {
    var title: String
    var width: CGFloat
    
    @State private var height: CGFloat
    @State private var offsetAmount: CGFloat = 5
    @State private var cardAmount: Int = 3
    
    @State private var hover: Bool = false
    
    init(title: String, width: CGFloat = 450) {
        self.title = title
        self.width = width
        self.height = self.width * (3/5)
    }
    
    var body: some View {
        let elem = AnyView(
            Text(self.title)
                .multilineTextAlignment(.center)
                .padding()
        )
        ZStack {
            ForEach(0..<self.cardAmount, id:\.self) { i in
                cardStruct(elem: elem, width: self.width - (CGFloat(self.cardAmount) * self.offsetAmount))
                    .offset(x: ((CGFloat(i) * -self.offsetAmount) + self.offsetAmount), y: ((CGFloat(i) * self.offsetAmount) - self.offsetAmount))
            }
        }
        .onHover { hover in
            self.hover = hover
        }
        .offset(x: 0, y: self.hover ? -2 : 0)
        .scaleEffect(self.hover ? 1.01 : 1)
        .animation(.interpolatingSpring(stiffness: 180, damping: 100))
        .frame(width: self.width, height: self.height, alignment: .center)
        .help("View Deck")
    }
}

struct studyNav: View {
    @State var current: Int
    
    @StateObject var viewManager: viewsManager
        
    var funcExec: () -> Void = { }
    
    var body: some View {
        HStack {
            Spacer()
            
            Picker("", selection: self.$current) {
                Label("Flashcards", systemImage: "").tag(0)
                Label("Test", systemImage: "").tag(1)
                Label("Quiz", systemImage: "").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: self.current) { _ in
                closeAll()
                if self.current == 0 {
                    self.viewManager.views.fullView = true
                } else if self.current == 1 {
                    self.viewManager.views.testView = true
                } else if self.current == 2 {
                    self.viewManager.views.quizView = true
                }
            }
            .padding(.trailing)
            
            Spacer()
            
            Button(action: {
                self.viewManager.views.helpAlert.toggle()
            }, label: {
                Image(systemName: "questionmark")
                    .foregroundColor(Color(NSColor.labelColor))
            })
            .alert(isPresented: self.$viewManager.views.helpAlert) {
                Alert(
                    title: Text("Help"),
                    message: Text("Use this top navigation bar to quickly flip between study modes.\n\nUse the navigation bar on the left to scroll to cards (Flashcard and Edit mode)\n\nPress the card to flip and swipe the card left or right to dismiss (Test and Quiz mode)")
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing)
            .help("Help")
            
            Button(action: {
                closeAll()
            }, label: {
                Image(systemName: "xmark")
                    .foregroundColor(Color(NSColor.labelColor))
            })
            .buttonStyle(PlainButtonStyle())
            .help("Close View")
        }
        .padding()
        .background(Color("nav_bkgColor_top"))
        .overlay(Divider().background(Color(NSColor.gridColor)), alignment: .bottom)
    }
    
    private func closeAll() {
        self.funcExec()
        self.viewManager.views.fullView = false
        self.viewManager.views.testView = false
        self.viewManager.views.quizView = false
        self.viewManager.views.creationView = false
    }
}
