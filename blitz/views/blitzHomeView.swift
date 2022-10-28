//
//  blitzHomeView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/25/22.
//

import SwiftUI

struct blitzHomeView: View {
    @StateObject private var userDataStore = userStore()
    
    @State private var creationView = false
    @State private var testView = false
    @State private var fullView = false
    @State private var quizView = false
    
    @State private var cols: Int = 3
    
    var width: CGFloat = 200
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack {
                    Label("Home", systemImage: "house")
                        .foregroundColor(Color(NSColor.headerTextColor))
                        .padding(.top, 15)
                        .padding(.bottom, 5)
                    
                    Divider().padding(.horizontal, 20)
                    
                    List {
                        ForEachIndexed(self.$userDataStore.userData.decks) { index, elem in
                            Text(elem.wrappedValue.title == "" ? "Deck \(index + 1)" : elem.wrappedValue.title)
                                .onTapGesture {
                                    openDeck(index: index)
                                    self.fullView = true
                                }
                        }
                        
                        Text("New Deck")
                            .foregroundColor(Color(NSColor.tertiaryLabelColor))
                            .onTapGesture {
                                createDeck()
                            }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }

                ScrollView(.vertical) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:self.width), spacing: 10, alignment: .leading)]) {
                        addDeck(width: self.width)
                            .onTapGesture {
                                createDeck()
                            }
                        
                        ForEachIndexed(self.$userDataStore.userData.decks) { index, elem in
                            cardStack(title: elem.title.wrappedValue, width: self.width)
                                .onTapGesture {
                                    openDeck(index: index)
                                    self.fullView = true
                                }
                                .contextMenu {
                                    Button {
                                        openDeck(index: index)
                                        self.fullView = true
                                    } label: {
                                        Text("Full View")
                                    }
                                    Button {
                                        openDeck(index: index)
                                        self.testView = true
                                    } label: {
                                        Text("Test View")
                                    }
                                    Button {
                                        openDeck(index: index)
                                        self.quizView = true
                                    } label: {
                                        Text("Quiz View")
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .sheet(isPresented: self.$creationView) {
                    deckCreation(creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
                .sheet(isPresented: self.$testView) {
                    deckTestView(creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
                .sheet(isPresented: self.$fullView) {
                    deckFullView(creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
                .sheet(isPresented: self.$quizView) {
                    deckQuizView(creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
            } // nav
        } // geo
        .onChange(of: self.creationView) { _bind in
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                }
            }
        }
        .onChange(of: self.testView) { _bind in
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                }
            }
        }
        .onChange(of: self.quizView) { _bind in
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                }
            }
        }
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
        .frame(minWidth: 800, minHeight: 400)
    } // body
    
    private func createDeck() {
        self.userDataStore.userData.append(deck: deck())
        openDeck(index: self.userDataStore.userData.decks.count - 1)
        self.creationView = true
    }
    private func openDeck(index: Int) {
        self.userDataStore.userData.changeIndex(index: index)
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
            
            
//ForEach(0..<Int(ceil(Double(self.userDataDecks.count + 1) / Double(self.cols))), id:\.self) { i in
//    HStack {
//        if i == 0 {
//            addDeck(width: self.width, press: self.$deckCreationPresented)
//
//            ForEach(0..<(self.cols - 1), id:\.self) { j in
//                if ((i * (self.cols - 1)) + j) < (self.userDataDecks.count + 1) {
//                    cardStack(title: self.userDataDecks[(i * (self.cols - 1)) + j].title, width: self.width, press: self.$deckTestPresented)
//                        .padding(.horizontal, 5)
//                        .padding(.vertical, 10)
//                        .onTapGesture {
//                            self.clickedDeck = (i * (self.cols - 1)) + j
//                        }
//                }
//            }
//        } else {
//            ForEach(0..<self.cols, id:\.self) { j in
//                if ((i * self.cols) + j - 1) < (self.userDataDecks.count) {
//                    cardStack(title: self.userDataDecks[(i * self.cols) + j - 1].title, width: self.width, press: self.$deckTestPresented)
//                        .padding(.horizontal, 5)
//                        .padding(.vertical, 10)
//                        .onTapGesture {
//                            self.clickedDeck = (i * self.cols) + j - 1
//                        }
//                }
//            }
//        }
//    }
//    .padding(.horizontal, 10)
//    .frame(width: geo.size.width - 14)
//}
//.frame(width: geo.size.width)
//.onChange(of: geo.size.width, perform : { _width in
//    self.cols = max(Int(floor((_width - 100) / (self.width + 10))), 1)
//})

struct blitzHomeView_Previews: PreviewProvider {
    static var previews: some View {
        blitzHomeView()
    }
}


// Add Deck View
struct addDeck: View {
    var width: CGFloat = 450
    
    @State private var hover: Bool = false
    
    var body: some View {
        let elem = AnyView(
            Image(systemName: "plus")
                .resizable()
                .padding(25)
                .multilineTextAlignment(.center)
                .foregroundColor(.blue)
                .frame(width: self.width - 100, height: self.width - 100)
        )
        cardStruct(elem: elem, width: self.width)
            .onHover { hover in self.hover = hover }
            .offset(x: 0, y: self.hover ? -2 : 0)
            .scaleEffect(self.hover ? 1.01 : 1)
            .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
}

// Card Stack View
struct cardStack: View {
    var title: String
    var width: CGFloat
    
    @State private var height: CGFloat
    @State private var offsetAmount: CGFloat = 5
    @State private var cardAmount = 3
    
    @State private var hover: Bool = false
    
    init(title: String, width: CGFloat = 450) {
        self.title = title
        self.width = width
        self.height = self.width * (3/5)
    }
    
    var body: some View {
        let elem = AnyView(
            Text(self.title)
        )
        ZStack {
            ForEach(0..<self.cardAmount) { i in
                cardStruct(elem: elem, width: self.width - (CGFloat(self.cardAmount) * self.offsetAmount))
                    .offset(x: ((CGFloat(i) * -self.offsetAmount) + self.offsetAmount), y: ((CGFloat(i) * self.offsetAmount) - self.offsetAmount))
            }
        }
        .onHover { hover in self.hover = hover }
        .offset(x: 0, y: self.hover ? -2 : 0)
        .scaleEffect(self.hover ? 1.01 : 1)
        .animation(.interpolatingSpring(stiffness: 180, damping: 100))
        .frame(width: self.width, height: self.height, alignment: .center)
    }
}
