//
//  deck.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI


struct deck: Codable, Identifiable, Hashable {
    let id: UUID
    var title = ""
    var cards = [card]()
    
    init(id: UUID = UUID(), title: String, cards: [card]) {
        self.id = id
        self.title = title
        self.cards = cards
    }
        
    static var example: deck {
        deck(title: "Example", cards: [card.example, card.example1])
    }
    static var example1: deck {
        deck(title: "Example 1", cards: [card.example1, card.example])
    }
    static var example2: deck {
        deck(title: "Example 2", cards: [card.example1, card.example])
    }
    static var example3: deck {
        deck(title: "Example 3", cards: [card.example1, card.example])
    }
}
