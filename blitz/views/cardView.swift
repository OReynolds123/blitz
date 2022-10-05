//
//  cardView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI

struct cardView_text: View, Identifiable {
    var id = UUID()
    var card: card
    var width: CGFloat = 450
    
    @State private var press: Bool = false
    @State private var hover: Bool = false
    
    var body: some View {
        let elem = AnyView(
            VStack {
                if !self.press {
                    Text(self.card.front)
                } else {
                    Text(self.card.back)
                        .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
                }
            }
            .padding(25)
            .multilineTextAlignment(.center)
            .lineLimit(10)
        )
        cardView(elem: elem, width: self.width, press: self.$press, hover: self.$hover)
    }
}

struct cardView_Previews: PreviewProvider {
    static var previews: some View {
        cardView_text(card: card.example)
    }
}

// Card View
struct cardView: View {
    var elem: AnyView
    var width: CGFloat
    
    @Binding var press: Bool
    @Binding var hover: Bool
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, press: Binding<Bool> = .constant(false), hover: Binding<Bool> = .constant(false)) {
        self.elem = elem
        self.width = width
        self._press = press
        self._hover = hover
    }
    
    var body: some View {
        cardStruct_bindings(elem: elem, width: self.width, press: self.$press, hover: self.$hover)
            .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
            .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
}

// Card View (No bindings)
struct cardView_noBindings: View {
    var elem: AnyView
    var width: CGFloat
    
    @Binding var press: Bool
    @Binding var hover: Bool
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, press: Binding<Bool> = .constant(false), hover: Binding<Bool> = .constant(false)) {
        self.elem = elem
        self.width = width
        self._press = press
        self._hover = hover
    }
    
    var body: some View {
        cardStruct(elem: elem, width: self.width)
            .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
            .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
}

// Main Card Structs
struct cardStruct_bindings: View {
    var elem: AnyView
    var width: CGFloat
    
    @Binding var press: Bool
    @Binding var hover: Bool
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, press: Binding<Bool> = .constant(false), hover: Binding<Bool> = .constant(false)) {
        self.elem = elem
        self.width = width
        self._press = press
        self._hover = hover
    }
    
    var body: some View {
        cardStruct(elem: self.elem, width: self.width)
            .onHover { hover in self.hover = hover }
            .onTapGesture { self.press.toggle() }
    }
}
struct cardStruct: View {
    var elem: AnyView
    var width: CGFloat
    
    @State private var height: CGFloat
    @State private var radius: CGFloat
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450) {
        self.elem = elem
        self.width = width
        self.height = self.width * (3/5)
        self.radius = sqrt(self.width)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: self.radius, style: .continuous)
                .fill(Color(NSColor.white))
                .background(RoundedRectangle(cornerRadius: self.radius, style: .continuous).fill(Color(NSColor.windowBackgroundColor)))
                .shadow(color: Color.black.opacity(0.2), radius: (self.radius / 5), x: 2, y: 2)
            
            self.elem
        }
        .frame(width: self.width, height: self.height)
        .accessibility(addTraits: .isButton)
    }
}
