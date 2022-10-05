//
//  blitzHomeView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/25/22.
//

import SwiftUI

struct blitzHomeView: View {
    @StateObject private var userDataStore = userStore()
    
    @State var deckCreationPresented = false
    @State var deckTestPresented = false
    
    @State private var clickedDeck: Int = 0
    @State private var cols: Int = 3
    
    var width: CGFloat = 200
    
    var body: some View {
        NavigationView {
            VStack {
                Label("Home", systemImage: "house")
                    .foregroundColor(Color(NSColor.headerTextColor))
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                
                Divider().padding(.horizontal, 20)
                
                List {
                    ForEachIndexed(self.$userDataStore.userData.decks) { index, elem in
                        Label(elem.wrappedValue.title == "" ? "Deck \(index + 1)" : elem.wrappedValue.title, systemImage: "")
                            .onTapGesture {
                                self.clickedDeck = index
                                self.deckTestPresented = true
                            }
                    }
                    
                    Label("New Deck", systemImage: "")
                        .onTapGesture {
                            createDeck()
                        }
                }
                
                Spacer()
            }
            
            GeometryReader { geo in
                ScrollView(.vertical) {
                    LazyVGrid(columns: [GridItem(.fixed(self.width)), GridItem(.fixed(self.width)), GridItem(.fixed(self.width))]) {
                        addDeck(width: self.width)
                            .onTapGesture {
                                createDeck()
                            }
                        
                        ForEachIndexed(self.$userDataStore.userData.decks) { index, elem in
                            cardStack(title: elem.title.wrappedValue, width: self.width)
                                .onTapGesture {
                                    self.clickedDeck = index
                                    self.deckTestPresented = true
                                }
                        }
                    }
                    .padding()
                }
                .sheet(isPresented: self.$deckCreationPresented) {
                    deckCreation(index: self.clickedDeck, creationPresented: self.$deckCreationPresented, testPresented: self.$deckTestPresented)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
                .sheet(isPresented: self.$deckTestPresented) {
                    deckTestView(index: self.clickedDeck, testPresented: self.$deckTestPresented, creationPresented: self.$deckCreationPresented)
                        .frame(width: geo.size.width - 10, height: geo.size.height - 10, alignment: .center)
                }
            }
        }
        .onChange(of: self.deckCreationPresented) { _bind in
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
    }
    
    private func createDeck() {
        self.userDataStore.userData.append(deck: deck())
        userStore.save(user: self.userDataStore.userData) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let uuid):
                print(uuid)
            }
        }
        self.clickedDeck = self.userDataStore.userData.decks.count - 1
        self.deckCreationPresented = true
    }
}
            
            
//                    ForEach(0..<Int(ceil(Double(self.userDataDecks.count + 1) / Double(self.cols))), id:\.self) { i in
//                        HStack {
//                            if i == 0 {
//                                addDeck(width: self.width, press: self.$deckCreationPresented)
//
//                                ForEach(0..<(self.cols - 1), id:\.self) { j in
//                                    if ((i * (self.cols - 1)) + j) < (self.userDataDecks.count + 1) {
//                                        cardStack(title: self.userDataDecks[(i * (self.cols - 1)) + j].title, width: self.width, press: self.$deckTestPresented)
//                                            .padding(.horizontal, 5)
//                                            .padding(.vertical, 10)
//                                            .onTapGesture {
//                                                self.clickedDeck = (i * (self.cols - 1)) + j
//                                            }
//                                    }
//                                }
//                            } else {
//                                ForEach(0..<self.cols, id:\.self) { j in
//                                    if ((i * self.cols) + j - 1) < (self.userDataDecks.count) {
//                                        cardStack(title: self.userDataDecks[(i * self.cols) + j - 1].title, width: self.width, press: self.$deckTestPresented)
//                                            .padding(.horizontal, 5)
//                                            .padding(.vertical, 10)
//                                            .onTapGesture {
//                                                self.clickedDeck = (i * self.cols) + j - 1
//                                            }
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 10)
//                        .frame(width: geo.size.width - 14)
//                    }
//                    .frame(width: geo.size.width)
//                    .onChange(of: geo.size.width, perform : { _width in
//                        self.cols = max(Int(floor((_width - 100) / (self.width + 10))), 1)
//                    })

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
            .offset(x: 0, y: self.hover ? -10 : 0)
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
        .offset(x: 0, y: self.hover ? -10 : 0)
        .scaleEffect(self.hover ? 1.01 : 1)
        .animation(.interpolatingSpring(stiffness: 180, damping: 100))
        .frame(width: self.width, height: self.height, alignment: .center)
    }
}
