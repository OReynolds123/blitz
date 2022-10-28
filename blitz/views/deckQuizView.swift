//
//  deckQuizView.swift
//  blitz
//
//  Created by Owen Reynolds on 10/25/22.
//

import SwiftUI

struct deckQuizView: View {
    @StateObject private var userDataStore = userStore()
    
    var width: CGFloat
    @Binding var creationView: Bool
    @Binding var testView: Bool
    @Binding var fullView: Bool
    @Binding var quizView: Bool
        
    @State private var deckTitle: String = ""
    @State private var deckCards: [card] = []
    @State private var deckCardsViews: [cardView_text] = []
    @State private var deckCard_frontIndex = -1
    @State private var deckCard_backIndex = -1

    @State private var height: CGFloat

    @GestureState private var dragState = DragState.inactive
    @State private var removalTransition  = AnyTransition.trailingBottom
    private let dragThreshold: CGFloat = 80.0

    init(width: CGFloat = 450, creationView: Binding<Bool>, testView: Binding<Bool>, fullView: Binding<Bool>, quizView: Binding<Bool>) {
        self.width = width
        self.height = self.width * (3/5)
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
                        saveUserData()
                        self.quizView = false
                    }

                Divider().padding(.horizontal, 20)

                List {
                    Text(self.deckTitle == "" ? "Deck Title" : self.deckTitle)
                    
                    ForEachIndexed(self.$deckCards) { index, elem in
                        Text(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front)
                            .foregroundColor(elem.wrappedValue.quiz_passed ? Color.green : elem.wrappedValue.quiz_failed ? Color.red : Color(NSColor.secondaryLabelColor))
                    }
                }
                .padding()

                Spacer()

                Divider().padding(.horizontal, 20)

                Text("Edit")
                    .foregroundColor(Color(NSColor.textColor))
                    .padding(.vertical, 5)
                    .onTapGesture {
                        saveUserData()
                        self.quizView = false
                        self.creationView = true
                    }

                Text("Close")
                    .foregroundColor(Color(NSColor.linkColor))
                    .padding(.bottom, 15)
                    .onTapGesture {
                        saveUserData()
                        self.quizView = false
                    }
            } // vstack

            ZStack {
                VStack {
                    Text("Reset the cards or add more!")
                    HStack {
                        VStack {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .resizable()
                                .frame(width: 15, height: 15)
                            
                            Text("Reset")
                                .offset(x: 0, y:-5)
                        }
                        .foregroundColor(Color(NSColor.linkColor))
                        .onTapGesture {
                            self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].quiz_reset()
                            userStore.save(user: self.userDataStore.userData) { result in
                                switch result {
                                case .failure(let error):
                                    fatalError(error.localizedDescription)
                                case .success(let uuid):
                                    print(uuid)
                                }
                            }
                            self.deckCards = self.userDataStore.userData.getDeck().cards
                            self.deckCard_frontIndex = -1
                            self.deckCard_backIndex = -1
                            self.deckCardsViews = {
                                var views = [cardView_text]()
                                var amt = 0
                                for index in 0..<self.deckCards.count {
                                    if (amt >= 2) { break }
                                    if (!self.deckCards[index].quiz_passed) {
                                        if (amt == 0) {
                                            self.deckCard_frontIndex = index
                                        } else if (amt == 1) {
                                            self.deckCard_backIndex = index
                                        }
                                        views.append(cardView_text(card: self.deckCards[index]))
                                        amt += 1
                                    }
                                }
                                return views
                            }()
                        }
                        
                        Spacer()
                        Divider().frame(height: 40)
                        Spacer()
                        
                        VStack {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 15, height: 15)
                            
                            Text("Add")
                                .offset(x: 0, y:-5)
                        }
                        .foregroundColor(Color(NSColor.labelColor))
                        .onTapGesture {
                            saveUserData()
                            self.quizView = false
                            self.creationView = true
                        }
                    }
                    .frame(width: 100)
                }
                
                ForEach(deckCardsViews) { deckCard in
                    deckCard
                        .zIndex(self.isTopCard(deckCard: deckCard) ? 1 : 0)
                        .overlay(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color.red.opacity(0.2))
                                    .opacity(self.dragState.translation.width < -self.dragThreshold && self.isTopCard(deckCard: deckCard) ? 1.0 : 0)

                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color.green.opacity(0.2))
                                    .opacity(self.dragState.translation.width > self.dragThreshold  && self.isTopCard(deckCard: deckCard) ? 1.0 : 0.0)
                            }
                        )
                        .offset(x: self.isTopCard(deckCard: deckCard) ? self.dragState.translation.width : 0, y: self.isTopCard(deckCard: deckCard) ? self.dragState.translation.height : 0)
                        .scaleEffect(self.dragState.isDragging && self.isTopCard(deckCard: deckCard) ? 0.95 : 1.0)
                        .rotationEffect(Angle(degrees: self.isTopCard(deckCard: deckCard) ? Double( self.dragState.translation.width / 10) : 0))
                        .animation(.interpolatingSpring(stiffness: 180, damping: 100))
                        .transition(self.removalTransition)
                        .gesture(LongPressGesture(minimumDuration: 0.01)
                            .sequenced(before: DragGesture())
                            .updating(self.$dragState, body: { (value, state, transaction) in
                                switch value {
                                case .first(true):
                                    state = .pressing
                                case .second(true, let drag):
                                    state = .dragging(translation: drag?.translation ?? .zero)
                                default:
                                    break
                                }

                            })
                            .onChanged({ (value) in
                                guard case .second(true, let drag?) = value else {
                                    return
                                }
                                if drag.translation.width < -self.dragThreshold {
                                    self.removalTransition = .leadingBottom
                                }
                                if drag.translation.width > self.dragThreshold {
                                    self.removalTransition = .trailingBottom
                                }
                            })
                            .onEnded({ (value) in
                                guard case .second(true, let drag?) = value else {
                                    return
                                }
                                if drag.translation.width < -self.dragThreshold {
                                    self.moveCard(failed: true)
                                }
                                if drag.translation.width > self.dragThreshold {
                                    self.moveCard(failed: false)
                                }
                            })
                        )
                }
            } // zstack
            .padding()
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
                    self.deckCardsViews = {
                        var views = [cardView_text]()
                        var amt = 0
                        for index in 0..<self.deckCards.count {
                            if (amt >= 2) { break }
                            if (!self.deckCards[index].quiz_passed) {
                                if (amt == 0) {
                                    self.deckCard_frontIndex = index
                                } else if (amt == 1) {
                                    self.deckCard_backIndex = index
                                }
                                views.append(cardView_text(card: self.deckCards[index]))
                                amt += 1
                            }
                        }
                        return views
                    }()
                }
            }
        }
    } // body
    
    private func saveUserData() {
        self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards = self.deckCards
        userStore.save(user: self.userDataStore.userData) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let uuid):
                print(uuid)
            }
        }
    }

    private func isTopCard(deckCard: cardView_text) -> Bool {
        guard let index = self.deckCardsViews.firstIndex(where: { $0.id == deckCard.id }) else {
            return false
        }
        return index == 0
    }
    
    func getNextIndex() -> Int {
        var i = self.deckCard_frontIndex + 1
        var amt = 0
        while (amt < self.deckCards.count) {
            if (i >= self.deckCards.count) {
                i = 0
            }
            if (i == self.deckCard_frontIndex) {
                break
            }
            if (!self.deckCards[i].quiz_passed) {
                return i
            }
            i = i + 1
            amt = amt + 1
        }
        return -1
    }

    private func moveCard(failed: Bool = false) {
        var didRemove = false
        if (failed) {
            self.deckCards[self.deckCard_frontIndex].quizFailed()
        } else {
            self.deckCards[self.deckCard_frontIndex].quizPassed()
            self.deckCardsViews.removeFirst()
            didRemove = true
        }
        
        if (self.deckCard_backIndex != -1) {
            self.deckCard_frontIndex = self.deckCard_backIndex
            self.deckCard_backIndex = getNextIndex()
            if (didRemove == false) {
                self.deckCardsViews.removeFirst()
            }
        }
        
        if (self.deckCard_backIndex != -1) {
            self.deckCardsViews.append(cardView_text(card: self.deckCards[self.deckCard_backIndex]))
        }
    }
}

struct deckQuizView_Previews: PreviewProvider {
    static var previews: some View {
        deckQuizView(creationView: .constant(false), testView: .constant(false), fullView: .constant(false), quizView: .constant(false))
    }
}
