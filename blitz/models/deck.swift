//
//  deck.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI


struct deck: Codable, Identifiable, Hashable {
    let id: UUID
    var cards = [card]()
    
    init(id: UUID = UUID(), cards: [card]) {
        self.id = id
        self.cards = cards
    }
        
    static var example: deck {
        deck(cards: [card.example, card.example1])
    }
    static var example1: deck {
        deck(cards: [card.example1, card.example])
    }
}
