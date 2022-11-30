//
//  deckFullView.swift
//  blitz
//
//  Created by Owen Reynolds on 10/13/22.
//

import SwiftUI

struct deckFullView: View {
    @StateObject var userDataStore: userStore
    @StateObject var viewManager: viewsManager
    
    @State private var scrollIndex: Int?
        
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    self.scrollIndex = 0
                }, label: {
                    Text(self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].title == "" ? "Deck Title" : self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].title)
                        .foregroundColor(Color("nav_titleColor"))
                        .fontWeight(.semibold)
                        .font(.title3)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                })
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                .help("Scroll to Top")

                Divider().padding(.horizontal, 20)

                List {
                    ForEachIndexed(self.$userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards) { index, elem in
                        Button(action: {
                            self.scrollIndex = index
                        }, label: {
                            Text(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front)
                                .foregroundColor(Color("nav_textColor"))
                                .fontWeight(.medium)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                Spacer()

                Divider().padding(.horizontal, 20)

                Button(action: {
                    self.exit()
                    self.viewManager.views.creationView = true
                }, label: {
                    Text("Edit")
                        .foregroundColor(Color("nav_editColor"))
                        .padding(.vertical, 5)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Edit Deck")
                
                Button(action: {
                    self.exit()
                }, label: {
                    Text("Close")
                        .foregroundColor(Color("nav_closeColor"))
                        .padding(.bottom, 15)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Close View")
            } // vstack
            .background(Color("nav_bkg"))
            
            VStack {
                studyNav(current: 0, viewManager: self.viewManager)
                
                GeometryReader { geo in
                    ScrollView {
                        ScrollViewReader { (proxy: ScrollViewProxy) in
                            Color.clear
                                .frame(width: geo.size.width) // - 14
                                       
                            VStack {
                                ForEachIndexed(self.$userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards) { index, elem in
                                    fullCard(front: elem.wrappedValue.front, back: elem.wrappedValue.back)
                                        .id(index)
                                }
                                .onChange(of: self.scrollIndex) { target in
                                    if let target = target {
                                        self.scrollIndex = nil
                                        withAnimation {
                                            proxy.scrollTo(target, anchor: .center)
                                        }
                                    }
                                }
                            }
                            .padding([.leading, .bottom, .trailing])
                        }
                    } // scrollview
                    .frame(width: geo.size.width)
                } // geo
            } // vstack
        } // nav
        .touchBar() {
            Button(action: {
                self.exit()
            }, label: {
                Label("Home", systemImage: "house")
            })
            .buttonStyle(DefaultButtonStyle())
            
            Button(action: {
                self.exit()
                self.viewManager.views.fullView = true
            }, label: {
                Text("Flashcards")
            })
            .buttonStyle(DefaultButtonStyle())
            .foregroundColor(Color("nav_closeColor"))
            
            Button(action: {
                self.exit()
                self.viewManager.views.testView = true
            }, label: {
                Text("Test Mode")
            })
            .buttonStyle(DefaultButtonStyle())
            
            Button(action: {
                self.exit()
                self.viewManager.views.quizView = true
            }, label: {
                Text("Quiz Mode")
            })
            .buttonStyle(DefaultButtonStyle())
            
            Button(action: {
                self.exit()
                self.viewManager.views.creationView = true
            }, label: {
                Label("Edit", systemImage: "pencil")
            })
            .buttonStyle(DefaultButtonStyle())
        }
        .background(Color("windowBkg"))
        .onExitCommand {
            self.exit()
        }
    } // body
    
    private func saveUserData() {
        userStore.save(user: self.userDataStore.userData) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let uuid):
                print(uuid)
            }
        }
    }
    
    private func exit() {
        self.saveUserData()
        self.viewManager.views.fullView = false
    }
}

struct deckFullView_Previews: PreviewProvider {
    static var previews: some View {
        deckFullView(userDataStore: userStore(), viewManager: viewsManager())
    }
}

struct fullCard: View {
    var width: CGFloat = 450
    var front: String
    var back: String
    
    var radius: CGFloat = 10
    
    var fontColor = Color("defaultCardFontColor")
    var bkgColor = Color("defaultCardBkgColor")
    
    @State private var pad: CGFloat = 20
    
    var body: some View {
        let elem = AnyView(
            HStack {
                ZStack {
                    Text(self.front)
                        .foregroundColor(self.fontColor)
                        .padding(.horizontal, 10)
                        .padding(.leading, 5)
                        .padding(.vertical, 10)
                        .frame(maxWidth: self.width / 3, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                ZStack {
                    Text(self.back)
                        .foregroundColor(self.fontColor)
                        .padding(.horizontal, 10)
                        .padding(.trailing, 5)
                        .padding(.vertical, 10)
                        .frame(maxWidth: self.width / 1, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: self.width)
        )
        cardStruct_noHeight(elem: elem, width: self.width, radius: 10, bkgColor: self.bkgColor)
    }
}
