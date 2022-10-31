//
//  deckFullView.swift
//  blitz
//
//  Created by Owen Reynolds on 10/13/22.
//

import SwiftUI

struct deckFullView: View {
    @StateObject private var userDataStore = userStore()
    
    @Binding var creationView: Bool
    @Binding var testView: Bool
    @Binding var fullView: Bool
    @Binding var quizView: Bool
    
    @State private var deckTitle: String = ""
    @State private var deckCards: [card] = []
    @State private var scrollIndex: Int?
        
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    self.fullView = false
                }, label: {
                    Label("Home", systemImage: "house")
                        .foregroundColor(Color("nav_homeColor"))
                        .padding(.top, 15)
                        .padding(.bottom, 5)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Return Home")

                Divider().padding(.horizontal, 20)

                List {
                    Button(action: {
                        self.scrollIndex = 0
                    }, label: {
                        Text(self.deckTitle == "" ? "Deck Title" : self.deckTitle)
                            .foregroundColor(Color("nav_titleColor"))
                    })
                    .buttonStyle(PlainButtonStyle())

                    ForEachIndexed(self.$deckCards) { index, elem in
                        Button(action: {
                            self.scrollIndex = index
                        }, label: {
                            Text(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front)
                                .foregroundColor(Color("nav_textColor"))
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                Spacer()

                Divider().padding(.horizontal, 20)

                Button(action: {
                    self.fullView = false
                    self.creationView = true
                }, label: {
                    Text("Edit")
                        .foregroundColor(Color("nav_editColor"))
                        .padding(.vertical, 5)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Edit Deck")
                
                Button(action: {
                    self.fullView = false
                }, label: {
                    Text("Close")
                        .foregroundColor(Color("nav_closeColor"))
                        .padding(.bottom, 15)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Close View")
            } // vstack
            
            VStack {
                studyNav(current: 0, creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView)
                
                GeometryReader { geo in
                    ScrollView {
                        ScrollViewReader { (proxy: ScrollViewProxy) in
                            Color.clear
                                .frame(width: geo.size.width) // - 14
                                       
                            VStack {
                                ForEachIndexed(self.$deckCards) { index, elem in
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
        .onAppear {
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                    self.deckTitle = userData.getDeck().title
                    self.deckCards = userData.getDeck().cards
                }
            }
        }
    }
}

struct deckFullView_Previews: PreviewProvider {
    static var previews: some View {
        deckFullView(creationView: .constant(false), testView: .constant(false), fullView: .constant(false), quizView: .constant(false))
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
