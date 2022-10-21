//
//  deckFullView.swift
//  blitz
//
//  Created by Owen Reynolds on 10/13/22.
//

import SwiftUI

struct deckFullView: View {
    @StateObject private var userDataStore = userStore()
    
    @State var index: Int
    @Binding var creationView: Bool
    @Binding var testView: Bool
    @Binding var fullView: Bool
    @Binding var quizView: Bool
    
    @State private var deckTitle: String = ""
    @State private var deckCards: [card] = []
    @State private var scrollIndex: Int?
    
    init(index: Int, creationView: Binding<Bool>, testView: Binding<Bool>, fullView: Binding<Bool>, quizView: Binding<Bool>) {
        self.index = index
        self._creationView = creationView
        self._testView = testView
        self._fullView = fullView
        self._quizView = quizView
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Label("Home", systemImage: "house")
                    .foregroundColor(Color(NSColor.headerTextColor))
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .onTapGesture {
                        self.fullView = false
                    }

                Divider().padding(.horizontal, 20)

                List {
                    Text(self.deckTitle == "" ? "Deck Title" : self.deckTitle)
                        .onTapGesture {
                            self.scrollIndex = 0
                        }

                    ForEachIndexed(self.$deckCards) { index, elem in
                        Text(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front)
                            .onTapGesture {
                                self.scrollIndex = index
                            }
                    }
                }
                .padding(.horizontal)

                Spacer()

                Divider().padding(.horizontal, 20)

                Text("Edit")
                    .foregroundColor(Color(NSColor.textColor))
                    .padding(.vertical, 5)
                    .onTapGesture {
                        self.fullView = false
                        self.creationView = true
                    }

                Text("Close")
                    .foregroundColor(Color(NSColor.linkColor))
                    .padding(.bottom, 15)
                    .onTapGesture {
                        self.fullView = false
                    }
            } // vstack

            GeometryReader { geo in
                ScrollView {
                    ScrollViewReader { (proxy: ScrollViewProxy) in
                        Rectangle()
                            .foregroundColor(Color.clear)
                            .frame(width: geo.size.width)
                                   
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
                        .padding()
                    }
                }
                .frame(width: geo.size.width)
            }
        } // nav
        .onAppear {
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                    self.deckTitle = userData.decks[index].title
                    self.deckCards = userData.decks[index].cards
                }
            }
        }
    }
}

struct deckFullView_Previews: PreviewProvider {
    static var previews: some View {
        deckFullView(index: 0, creationView: .constant(false), testView: .constant(false), fullView: .constant(false), quizView: .constant(false))
    }
}

struct fullCard: View {
    var width: CGFloat = 450
    var front: String
    var back: String = ""
    
    var radius: CGFloat = 10
    
    @State private var pad: CGFloat = 20
    
    var body: some View {
        let elem = AnyView(
            HStack {
                ZStack {
                    Text(self.front)
                        .padding(.horizontal, 10)
                        .padding(.leading, 5)
                        .padding(.vertical, 10)
                        .frame(maxWidth: self.width / 3, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                ZStack {
                    Text(self.back)
                        .padding(.horizontal, 10)
                        .padding(.trailing, 5)
                        .padding(.vertical, 10)
                        .frame(maxWidth: self.width / 1, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: self.width)
        )
        cardStruct_noHeight(elem: elem, width: self.width, radius: 10)
    }
}

