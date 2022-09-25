//
//  user.swift
//  blitz
//
//  Created by Owen Reynolds on 9/23/22.
//

import Foundation


struct user: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String = ""
    var decks = [deck]()
    
    init(id: UUID = UUID(), decks: [deck]) {
        self.id = id
        self.decks = decks
    }
    
    static var example: user {
        user(decks: [deck.example, deck.example1])
    }
}
