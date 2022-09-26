//
//  blitzHomeView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/25/22.
//

import SwiftUI

struct blitzHomeView: View {
    var width: CGFloat = 200
    
    @State private var decks: [deck] = [deck.example, deck.example1, deck.example2, deck.example3, deck.example3, deck.example2, deck.example1, deck.example, deck.example]
    @State private var cols: Int = 3
    
    @State var showingAddDeck = false
    
    var body: some View {
        NavigationView {
            List {
                Label("", systemImage: "")
            }
            
            GeometryReader { geo in
                ScrollView {
                    Color.clear
                        .frame(width: geo.size.width, height: 0)
                        
                    ForEach(0..<Int(ceil(Double(self.decks.count + 1) / Double(self.cols))), id:\.self) { i in
                        HStack {
                            if i == 0 {
                                addDeck(width: self.width, press: self.$showingAddDeck)

                                ForEach(0..<(self.cols - 1), id:\.self) { j in
                                    if ((i * (self.cols - 1)) + j) < (self.decks.count + 1) {
                                        cardStack(title: self.decks[(i * (self.cols - 1)) + j].title, width: self.width)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 10)
                                    }
                                }
                            } else {
                                ForEach(0..<self.cols, id:\.self) { j in
                                    if ((i * self.cols) + j - 1) < (self.decks.count) {
                                        cardStack(title: self.decks[(i * self.cols) + j - 1].title, width: self.width)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                    }
                    
                }
                .frame(width: geo.size.width)
                .onChange(of: geo.size.width, perform : { _width in
                    self.cols = max(Int(floor((_width - 20) / (self.width + 10))), 1)
                })
            }
        }
        .sheet(isPresented: self.$showingAddDeck) {
            deckCreation(saveBtn: self.$showingAddDeck)
        }
    }
}

struct blitzHomeView_Previews: PreviewProvider {
    static var previews: some View {
        blitzHomeView()
    }
}


// Add Deck View
struct addDeck: View {
    var width: CGFloat = 450
    
    @Binding var press: Bool
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
        cardView_button(elem: elem, width: self.width, press: self.$press, hover: self.$hover)
    }
}

// Card Stack View
struct cardStack: View {
    var title: String
    var width: CGFloat
    
    @State private var press: Bool = false
    @State private var hover: Bool = false
    
    @State private var height: CGFloat
    @State private var offsetAmount: CGFloat = 10
    @State private var cardAmount = 3
    
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
                cardView_button(elem: elem, width: self.width - (CGFloat(self.cardAmount) * self.offsetAmount), press: self.$press, hover: self.$hover)
                    .offset(x: ((CGFloat(i) * -self.offsetAmount) + self.offsetAmount), y: ((CGFloat(i) * self.offsetAmount) - self.offsetAmount))
            }
        }
        .frame(width: self.width, height: self.height, alignment: .center)
    }
}
