//
//  deck.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI


struct deck: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String = ""
    var cards = [card]()
    
    init(id: UUID = UUID(), name: String, cards: [card]) {
        self.id = id
        self.name = name
        self.cards = cards
    }
    
    static var example: deck {
        deck(name: "example", cards: [card.example, card.example1])
    }
}
