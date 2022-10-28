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
    var fontColor: Color = Color("defaultCardFontColor")
    var bkgColor: Color = Color("defaultCardBkgColor")
    var width: CGFloat = 450
    
    @State private var press: Bool = false
    @State private var hover: Bool = false
    
    var body: some View {
        let elem = AnyView(
            VStack {
                if !self.press {
                    Text(self.card.front)
                        .foregroundColor(self.fontColor)
                } else {
                    Text(self.card.back)
                        .foregroundColor(self.fontColor)
                        .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
                }
            }
            .padding(25)
            .multilineTextAlignment(.center)
            .lineLimit(10)
        )
        cardView(elem: elem, width: self.width, bkgColor: self.bkgColor, press: self.$press, hover: self.$hover)
    }
}

struct cardView_Previews: PreviewProvider {
    static var previews: some View {
        cardView_text(card: card(front: "Test Front", back: "Test Back"))
    }
}

// Card View
struct cardView: View {
    var elem: AnyView
    var bkgColor: Color
    var width: CGFloat
    
    @Binding var press: Bool
    @Binding var hover: Bool
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, bkgColor: Color = Color("defaultCardBkgColor"), press: Binding<Bool> = .constant(false), hover: Binding<Bool> = .constant(false)) {
        self.elem = elem
        self.bkgColor = bkgColor
        self.width = width
        self._press = press
        self._hover = hover
    }
    
    var body: some View {
        cardStruct_bindings(elem: elem, width: self.width, bkgColor: self.bkgColor, press: self.$press, hover: self.$hover)
            .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
            .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
}

// Card View (No bindings)
struct cardView_noBindings: View {
    var elem: AnyView
    var bkgColor: Color
    var width: CGFloat
    
    @Binding var press: Bool
    @Binding var hover: Bool
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, bkgColor: Color = Color("defaultCardBkgColor"), press: Binding<Bool> = .constant(false), hover: Binding<Bool> = .constant(false)) {
        self.elem = elem
        self.bkgColor = bkgColor
        self.width = width
        self._press = press
        self._hover = hover
    }
    
    var body: some View {
        cardStruct(elem: elem, width: self.width, bkgColor: self.bkgColor)
            .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
            .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
}

// Main Card Structs
struct cardStruct_bindings: View {
    var elem: AnyView
    var bkgColor: Color
    var width: CGFloat
    
    @Binding var press: Bool
    @Binding var hover: Bool
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, bkgColor: Color = Color("defaultCardBkgColor"), press: Binding<Bool> = .constant(false), hover: Binding<Bool> = .constant(false)) {
        self.elem = elem
        self.bkgColor = bkgColor
        self.width = width
        self._press = press
        self._hover = hover
    }
    
    var body: some View {
        cardStruct(elem: self.elem, width: self.width, bkgColor: self.bkgColor)
            .onHover { hover in self.hover = hover }
            .onTapGesture { self.press.toggle() }
    }
}
struct cardStruct: View {
    var elem: AnyView
    var bkgColor: Color
    var width: CGFloat
    var height: CGFloat
    var radius: CGFloat
    
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, bkgColor: Color = Color("defaultCardBkgColor")) {
        self.elem = elem
        self.bkgColor = bkgColor
        self.width = width
        self.height = self.width * (3/5)
        self.radius = sqrt(self.width)
    }
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, bkgColor: Color = Color("defaultCardBkgColor"), height: CGFloat) {
        self.elem = elem
        self.bkgColor = bkgColor
        self.width = width
        self.height = height
        self.radius = sqrt(self.width)
    }
    init(elem: AnyView = AnyView(Color.clear), width: CGFloat = 450, bkgColor: Color = Color("defaultCardBkgColor"), height: CGFloat, radius: CGFloat) {
        self.elem = elem
        self.bkgColor = bkgColor
        self.width = width
        self.height = height
        self.radius = radius
    }
    
    var body: some View {
        self.elem
            .background(
                RoundedRectangle(cornerRadius: self.radius, style: .continuous)
                    .fill(self.bkgColor)
                    .shadow(color: Color.black.opacity(0.2), radius: (self.radius / 5), x: 2, y: 2)
                    .frame(width: self.width, height: self.height)
            )
            .frame(width: self.width, height: self.height)
            .accessibility(addTraits: .isButton)
    }
}
struct cardStruct_noHeight: View {
    var elem: AnyView = AnyView(Color.clear)
    var width: CGFloat
    var radius: CGFloat
    var bkgColor: Color = Color("defaultCardBkgColor")
    
    var body: some View {
        self.elem
            .background(
                RoundedRectangle(cornerRadius: self.radius, style: .continuous)
                    .fill(self.bkgColor)
                    .shadow(color: Color.black.opacity(0.2), radius: (self.radius / 5), x: 2, y: 2)
            )
        .frame(width: self.width)
        .accessibility(addTraits: .isButton)
    }
}
