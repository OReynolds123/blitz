//
//  blitzHomeView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/25/22.
//

import SwiftUI

struct blitzHomeView: View {
    var width: CGFloat = 200
    var height: CGFloat = 125
    
    @State private var decks: [deck] = []
    
    var body: some View {
        NavigationView {
            List {
                Label("", systemImage: "")
            }
            
            GeometryReader { geo in
                ScrollView {
                    Color.clear
                        .frame(width: geo.size.width, height: 0)
                    
                    HStack {
                        addDeck(width: self.width)
                        
                        cardStack(title: "Deck Title", width: self.width)
                        
                        cardStack(title: "Deck Title", width: self.width)
                        
                        cardStack(title: "Deck Title", width: self.width)
                        
                    }
                }
                .frame(width: geo.size.width)
            }
        }
    }
}

struct blitzHomeView_Previews: PreviewProvider {
    static var previews: some View {
        blitzHomeView()
            .frame(width: 1000, height: 750)
    }
}


// Add Deck View
struct addDeck: View {
    var width: CGFloat = 450
    
    @State private var press: Bool = false
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
