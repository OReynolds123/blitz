//
//  deckTestView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI

struct deckTestView: View {
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
    @State private var cardSide: Bool = false

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
                        self.testView = false
                    }

                Divider().padding(.horizontal, 20)

                List {
                    Text(self.deckTitle == "" ? "Deck Title" : self.deckTitle)
                    
                    ForEachIndexed(self.$deckCards) { index, elem in
                        Text(self.cardSide ? (elem.wrappedValue.back == "" ? "Card \(index + 1)" : elem.wrappedValue.back) : (elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front))
                            .foregroundColor(elem.wrappedValue.test_passed ? Color.green : elem.wrappedValue.test_failed ? Color.red : Color(NSColor.secondaryLabelColor))
                    }
                }
                .padding()

                Spacer()
                
                Toggle("Flip Cards?", isOn: self.$cardSide)

                Divider().padding(.horizontal, 20)

                Text("Edit")
                    .foregroundColor(Color(NSColor.textColor))
                    .padding(.vertical, 5)
                    .onTapGesture {
                        saveUserData()
                        self.testView = false
                        self.creationView = true
                    }

                Text("Close")
                    .foregroundColor(Color(NSColor.linkColor))
                    .padding(.bottom, 15)
                    .onTapGesture {
                        saveUserData()
                        self.testView = false
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
                            self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].test_reset()
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
                            self.deckCardsViews = drawCardViews()
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
                            self.testView = false
                            self.creationView = true
                        }
                    }
                    .frame(width: 100)
                }
                
                ForEach(deckCardsViews) { deckCard in
                    deckCard
                        .zIndex(self.isTopCard(deckCard: deckCard) ? 1 : 0)
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
                                    self.deckCardsViews[0].bkgColor = Color("cardIncorrectBkgColor")
                                } else if drag.translation.width > self.dragThreshold {
                                    self.removalTransition = .trailingBottom
                                    self.deckCardsViews[0].bkgColor = Color("cardCorrectBkgColor")
                                } else {
                                    self.deckCardsViews[0].bkgColor = Color("defaultCardBkgColor")
                                }
                            })
                            .onEnded({ (value) in
                                guard case .second(true, let drag?) = value else {
                                    return
                                }
                                if drag.translation.width < -self.dragThreshold {
                                    self.moveCard(failed: true)
                                } else if drag.translation.width > self.dragThreshold {
                                    self.moveCard(failed: false)
                                }
                            })
                        )
                }
            } // zstack
            .padding()
        } // nav
        .onChange(of: self.cardSide) { _bind in
            for i in 0..<self.deckCardsViews.count {
                self.deckCardsViews[i] = cardView_text(card: self.deckCardsViews[i].card, width: self.width, reverse: self.cardSide)
            }
        }
        .onAppear {
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                    self.deckTitle = userData.getDeck().title
                    self.deckCards = userData.getDeck().cards
                    self.deckCardsViews = drawCardViews()
                }
            }
        }
    } // body
    
    private func drawCardViews() -> [cardView_text] {
        var views: [cardView_text] = []
        var amt = 0
        for index in 0..<self.deckCards.count {
            if (amt >= 2) { break }
            if (!self.deckCards[index].quiz_passed) {
                if (amt == 0) {
                    self.deckCard_frontIndex = index
                } else if (amt == 1) {
                    self.deckCard_backIndex = index
                }
                views.append(cardView_text(card: self.deckCards[index], width: self.width, reverse: self.cardSide))
                amt += 1
            }
        }
        return views
    }
    
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
            if (!self.deckCards[i].test_passed) {
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
            self.deckCards[self.deckCard_frontIndex].testFailed()
        } else {
            self.deckCards[self.deckCard_frontIndex].testPassed()
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

struct deckTestView_Previews: PreviewProvider {
    static var previews: some View {
        deckTestView(creationView: .constant(false), testView: .constant(false), fullView: .constant(false), quizView: .constant(false))
    }
}


enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)
    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    var isDragging: Bool {
        switch self {
        case .dragging:
            return true
        case .pressing, .inactive:
            return false
        }
    }
    var isPressing: Bool {
        switch self {
        case .pressing, .dragging:
            return true
        case .inactive:
            return false
        }
    }
}

extension AnyTransition {
    static var trailingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .trailing).combined(with: .move(edge: .bottom))
        )

    }
    static var leadingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .leading).combined(with: .move(edge: .bottom))
        )
    }
}
