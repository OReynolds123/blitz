//
//  cardView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI

struct cardView: View, Identifiable {
    var id = UUID()
    var card: card
    var allowTap: Bool = true
    var width: CGFloat = 450
    var height: CGFloat = 250
    
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            cardBkg()
            
            VStack {
                if !self.isFlipped {
                    Text(self.card.front)
                } else {
                    Text(self.card.back)
                        .rotation3DEffect(.degrees(self.isFlipped ? 180 : 0), axis: (x: -1, y: 0, z: 0))
                }
            }
            .padding(25)
            .multilineTextAlignment(.center)
            .lineLimit(10)
        }
        .frame(width: self.width, height: self.height)
        .accessibility(addTraits: .isButton)
        .onTapGesture { if self.allowTap { self.isFlipped.toggle() } }
        .rotation3DEffect(.degrees(self.isFlipped ? 180 : 0), axis: (x: -1, y: 0, z: 0))
        .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
}

struct cardView_Previews: PreviewProvider {
    static var previews: some View {
        cardView(card: card.example)
    }
}
