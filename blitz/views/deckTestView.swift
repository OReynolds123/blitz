//
//  deckTestView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI

struct deckTestView: View {
    var width: CGFloat
    @Binding var editBtn: Bool
    @Binding var presented: Bool
    @Binding var deck: deck
    
    @State private var deckTitle: String = ""
    @State private var deckCards: [card] = []
    @State private var deckCardsViews: [cardView_text] = []
    
    @State private var scrollIndex: Int?
    @State private var height: CGFloat
    
    
    @GestureState private var dragState = DragState.inactive
    
    @State private var lastIndex = 1
    @State private var removalTransition  = AnyTransition.trailingBottom
    private let dragThreshold: CGFloat = 80.0
    
    
    init(width: CGFloat = 450, editBtn: Binding<Bool>, presented: Binding<Bool>, deck: Binding<deck>) {
        self.width = width
        self.height = self.width * (3/5)
        self._editBtn = editBtn
        self._presented = presented
        self._deck = deck
        self.deckTitle = self.deck.title
        self.deckCards = self.deck.cards
        self.deckCardsViews = [cardView_text(card: self.deckCards[0]),cardView_text(card: self.deckCards[1])]
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Label("Home", systemImage: "house")
                    .foregroundColor(.black)
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .onTapGesture {
                        self.editBtn = false
                        self.presented = false
                    }
                
                Divider().padding(.horizontal, 20)
                
                List {
                    Label(deckTitle == "" ? "Deck Title" : deckTitle, systemImage: "home")
                        .onTapGesture {
                            self.scrollIndex = 0
                        }

                    ForEachIndexed(self.$deckCards) { index, elem in
                        Label(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front, systemImage: "")
                            .onTapGesture {
                                self.scrollIndex = index + 1
                            }
                    }
                }

                Spacer()
                
                Divider().padding(.horizontal, 20)

                Label("Edit", systemImage: "")
                    .foregroundColor(.black)
                    .padding(.vertical, 5)
                    .onTapGesture {
                        self.editBtn = true
                        self.presented = false
                    }
                    
                Label("Close", systemImage: "")
                    .foregroundColor(.blue)
                    .padding(.bottom, 15)
                    .onTapGesture {
                        self.editBtn = false
                        self.presented = false
                    }
            }
            
            ZStack {
                ForEach(deckCardsViews) { deckCard in
                    deckCard
                        .zIndex(self.isTopCard(deckCard: deckCard) ? 1 : 0)
                        .overlay(
                            ZStack {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 100))
                                    .opacity(self.dragState.translation.width < -self.dragThreshold && self.isTopCard(deckCard: deckCard) ? 1.0 : 0)
    
                                Image(systemName: "heart.circle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 100))
                                    .opacity(self.dragState.translation.width > self.dragThreshold  && self.isTopCard(deckCard: deckCard) ? 1.0 : 0.0)
                            }
                        )
                        .offset(x: self.isTopCard(deckCard: deckCard) ? self.dragState.translation.width : 0, y: self.isTopCard(deckCard: deckCard) ? self.dragState.translation.height : 0)
                        .scaleEffect(self.dragState.isDragging && self.isTopCard(deckCard: deckCard) ? 0.95 : 1.0)
                        .rotationEffect(Angle(degrees: self.isTopCard(deckCard: deckCard) ? Double( self.dragState.translation.width / 10) : 0))
    //                    .opacity(self.isTopCard(cardView: cardView) ? 1 : 2 - Double(abs(self.dragState.translation.width / 50)))
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
                                if drag.translation.width < -self.dragThreshold ||
                                    drag.translation.width > self.dragThreshold {
                                    self.moveCard()
                                }
                            })
                        )
                }
            }
            
        }
    }
    
    private func isTopCard(deckCard: cardView_text) -> Bool {
        guard let index = self.deckCardsViews.firstIndex(where: { $0.id == deckCard.id }) else {
            return false
        }
        return index == 0
    }

    private func moveCard() {
        self.deckCardsViews.removeFirst()
        self.lastIndex += 1
        self.deckCardsViews.append(cardView_text(card: self.deckCards[self.lastIndex]))
    }
}

struct deckTestView_Previews: PreviewProvider {
    static var previews: some View {
        deckTestView(editBtn: .constant(false), presented: .constant(false), deck: .constant(deck.example))
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
