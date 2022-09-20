//
//  cardStackView.swift
//  blitz
//
//  Created by Capstone on 9/20/22.
//

import SwiftUI

struct cardStackView: View {
    var card: card
    var width: CGFloat = 450
    var height: CGFloat = 250
    var offsetAmount: Int = 25
    var cardAmount: Int = 3
    
    var body: some View {
        ZStack {
            ForEach(0..<self.cardAmount) { i in
                cardView(card: self.card, allowTap: false, width: self.width, height: self.height)
                    .offset(x: CGFloat((i * -self.offsetAmount) + self.offsetAmount), y: CGFloat((i * self.offsetAmount) - self.offsetAmount))
            }
        }
//        .offset(x: cardAmount % 2 == 0 ? CGFloat(self.offsetAmount) : 0, y: cardAmount % 2 == 0 ? CGFloat(-self.offsetAmount) : 0)
        .frame(width: (self.width + CGFloat(self.offsetAmount * (self.cardAmount - 1))), height: (self.height + CGFloat(self.offsetAmount * (self.cardAmount - 1))))
    }
}

struct cardStackView_Previews: PreviewProvider {
    static var previews: some View {
        cardStackView(card: card.example)
    }
}
