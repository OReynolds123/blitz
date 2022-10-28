//
//  deck.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI


struct deck: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var cards: [card]
//    var fontColor_r: CGFloat
//    var fontColor_g: CGFloat
//    var fontColor_b: CGFloat
//    var fontColor_a: CGFloat
//    var bkgColor_r: CGFloat
//    var bkgColor_g: CGFloat
//    var bkgColor_b: CGFloat
//    var bkgColor_a: CGFloat
    
    init(id: UUID = UUID(), title: String = "", cards: [card] = []) {
        self.id = id
        self.title = title
        self.cards = cards
        
//        self.fontColor_r = Color("defaultCardFontColor").cgColor?.components?[0] ?? 0
//        self.fontColor_g = Color("defaultCardFontColor").cgColor?.components?[1] ?? 0
//        self.fontColor_b = Color("defaultCardFontColor").cgColor?.components?[2] ?? 0
//        self.fontColor_a = Color("defaultCardFontColor").cgColor?.components?[3] ?? 1
//        self.bkgColor_r = Color("defaultCardBkgColor").cgColor?.components?[0] ?? 255
//        self.bkgColor_g = Color("defaultCardBkgColor").cgColor?.components?[1] ?? 255
//        self.bkgColor_b = Color("defaultCardBkgColor").cgColor?.components?[2] ?? 255
//        self.bkgColor_a = Color("defaultCardBkgColor").cgColor?.components?[3] ?? 1
    }
    
    mutating func append(card: card) {
        self.cards.append(card)
    }
    
    mutating func test_resetPassed() {
        var i = 0
        while(i < self.cards.count) {
            self.cards[i].test_passed = false
            i = i + 1
        }
    }
    mutating func test_resetFailed() {
        var i = 0
        while(i < self.cards.count) {
            self.cards[i].test_failed = false
            i = i + 1
        }
    }
    mutating func test_reset() {
        var i = 0
        while(i < self.cards.count) {
            self.cards[i].test_passed = false
            self.cards[i].test_failed = false
            i = i + 1
        }
    }
    
    mutating func quiz_resetPassed() {
        var i = 0
        while(i < self.cards.count) {
            self.cards[i].quiz_passed = false
            i = i + 1
        }
    }
    mutating func quiz_resetFailed() {
        var i = 0
        while(i < self.cards.count) {
            self.cards[i].quiz_failed = false
            i = i + 1
        }
    }
    mutating func quiz_reset() {
        var i = 0
        while(i < self.cards.count) {
            self.cards[i].quiz_passed = false
            self.cards[i].quiz_failed = false
            i = i + 1
        }
    }
    
//    func getFontColor() -> Color {
//        return Color(red: self.fontColor_r, green: self.fontColor_g, blue: self.fontColor_b, opacity: self.fontColor_a)
//    }
//    mutating func setFontColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
//        self.fontColor_r = r
//        self.fontColor_g = g
//        self.fontColor_b = b
//        self.fontColor_a = a
//    }
//    func getBkgColor() -> Color {
//        return Color(red: self.bkgColor_r, green: self.bkgColor_g, blue: self.bkgColor_b, opacity: self.bkgColor_a)
//    }
//    mutating func setBkgColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
//        self.bkgColor_r = r
//        self.bkgColor_g = g
//        self.bkgColor_b = b
//        self.bkgColor_a = a
//    }
    
    static var example: deck {
        deck(title: "Example", cards: [card.example, card.example1])
    }
    static var example1: deck {
        deck(title: "Example 1", cards: [card.example1, card.example])
    }
}
