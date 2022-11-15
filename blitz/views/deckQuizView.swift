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
    @State private var textInput: String = ""
    @State private var cardSide: Bool = false
    
    @State private var isCorrect: Bool = false
    @State private var isIncorrect: Bool = false
    @State private var wrongAttempts: Int = 0

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
                Button(action: {
//                    saveUserData()
//                    self.quizView = false
                }, label: {
                    Text(self.deckTitle == "" ? "Deck Title" : self.deckTitle)
                        .foregroundColor(Color("nav_titleColor"))
                        .fontWeight(.semibold)
                        .font(.title3)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                })
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
//                .help("Scroll to Top")

                Divider().padding(.horizontal, 20)

                List {
                    ForEachIndexed(self.$deckCards) { index, elem in
                        Text(self.cardSide ? (elem.wrappedValue.back == "" ? "Card \(index + 1)" : elem.wrappedValue.back) : (elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front))
                            .foregroundColor(elem.wrappedValue.quiz_passed ? Color("nav_correctColor") : elem.wrappedValue.quiz_failed ? Color("nav_incorrectColor") : Color("nav_textColor"))
                            .fontWeight(.medium)
                    }
                }
                .padding(.horizontal)

                Spacer()
                
                Button(action: {
                    self.cardSide.toggle()
                }, label: {
                    Text("Flip Cards")
                        .foregroundColor(Color("nav_flipColor"))
                })
                .buttonStyle(PlainButtonStyle())
                .help("Study the Other Side")
                
                Divider().frame(width: 40)
                
                Button(action: {
                    resetDeck()
                }, label: {
                    Text("Reset Cards")
                        .foregroundColor(Color("nav_saveColor"))
                })
                .buttonStyle(PlainButtonStyle())
                .help("Re-study the Deck")

                Divider().padding(.horizontal, 20)

                Button(action: {
                    saveUserData()
                    self.quizView = false
                    self.creationView = true
                }, label: {
                    Text("Edit")
                        .foregroundColor(Color("nav_editColor"))
                        .padding(.vertical, 5)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Edit Deck")
                
                Button(action: {
                    saveUserData()
                    self.quizView = false
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
                studyNav(current: 2, creationView: self.$creationView, testView: self.$testView, fullView: self.$fullView, quizView: self.$quizView, funcExec: saveUserData)
            
                VStack {
                    Spacer()
                    
                    ZStack {
                        VStack {
                            Text("Reset the cards or add more!")
                            HStack {
                                Button(action: {
                                    resetDeck()
                                }, label: {
                                    VStack {
                                        Image(systemName: "arrow.uturn.backward.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                        
                                        Text("Reset")
                                            .offset(x: 0, y:-5)
                                    }
                                    .foregroundColor(Color(NSColor.linkColor))
                                })
                                .buttonStyle(PlainButtonStyle())
                                .help("Re-study the Deck")
                                
                                Spacer()
                                Divider().frame(height: 40)
                                Spacer()
                                
                                Button(action: {
                                    saveUserData()
                                    self.quizView = false
                                    self.creationView = true
                                }, label: {
                                    VStack {
                                        Image(systemName: "plus.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                        
                                        Text("Add")
                                            .offset(x: 0, y:-5)
                                    }
                                    .foregroundColor(Color(NSColor.labelColor))
                                })
                                .buttonStyle(PlainButtonStyle())
                                .help("Edit Deck")
                            }
                            .frame(width: 100)
                        } // VStack
                        
                        ForEach(deckCardsViews) { deckCard in
                            deckCard
                                .zIndex(self.isTopCard(deckCard: deckCard) ? 1 : 0)
                                .modifier(Shake(animatableData: CGFloat(self.wrongAttempts))) // Shake on incorrect
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
                                            if self.isIncorrect {
                                                self.deckCardsViews[0].bkgColor = Color("cardIncorrectBkgColor")
                                            } else if self.isCorrect {
                                                self.deckCardsViews[0].bkgColor = Color("cardCorrectBkgColor")
                                            } else {
                                                self.deckCardsViews[0].bkgColor = Color("defaultCardBkgColor")
                                            }
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
                        } // Foreach
                    } // zstack
                    
                    Spacer()
                    
                    // Text Input
                    let elem = AnyView(
                        TextField("Type the answer here", text: self.$textInput, onCommit: {
                            if self.deckCardsViews.count == 0 { return }
                            var compareTxt = self.deckCards[self.deckCard_frontIndex].back
                            if (self.cardSide) {
                                compareTxt = self.deckCards[self.deckCard_frontIndex].front
                            }
                            if (self.textInput != compareTxt) {
                                withAnimation(.default) {
                                    self.wrongAttempts += 1
                                }
                                self.isIncorrect = true
                                self.isCorrect = false
                                self.deckCardsViews[0].bkgColor = Color("cardIncorrectBkgColor")
                            } else {
                                self.deckCardsViews[0].bkgColor = Color("cardCorrectBkgColor")
                                self.isIncorrect = false
                                self.isCorrect = true
                            }
                        })
                        .padding()
                        .multilineTextAlignment(.center)
                    )
                    cardStruct_noHeight(elem: elem, width: self.width, radius: 10)
                        .zIndex(-1)
                    
                } // vstack
                .padding()
            } // vstack
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
        .touchBar() {
            Button(action: {
                saveUserData()
                self.quizView = false
            }, label: {
                Label("Home", systemImage: "house")
            })
            .buttonStyle(DefaultButtonStyle())
            
            Button(action: {
                saveUserData()
                self.quizView = false
                self.fullView = true
            }, label: {
                Text("Flashcards")
            })
            .buttonStyle(DefaultButtonStyle())
            
            Button(action: {
                saveUserData()
                self.quizView = false
                self.testView = true
            }, label: {
                Text("Test Mode")
            })
            .buttonStyle(DefaultButtonStyle())
            
            Button(action: {
                saveUserData()
                self.quizView = false
                self.quizView = true
            }, label: {
                Text("Quiz Mode")
            })
            .buttonStyle(DefaultButtonStyle())
            .foregroundColor(Color("nav_closeColor"))
            
            Button(action: {
                saveUserData()
                self.quizView = false
                self.creationView = true
            }, label: {
                Label("Edit", systemImage: "pencil")
            })
            .buttonStyle(DefaultButtonStyle())
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
    
    private func resetDeck() {
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
        self.deckCardsViews = drawCardViews()
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
        self.isCorrect = false
        self.isIncorrect = false
        
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
            self.deckCardsViews.append(cardView_text(card: self.deckCards[self.deckCard_backIndex], width: self.width, reverse: self.cardSide))
        }
    }
}

struct deckQuizView_Previews: PreviewProvider {
    static var previews: some View {
        deckQuizView(creationView: .constant(false), testView: .constant(false), fullView: .constant(false), quizView: .constant(false))
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
