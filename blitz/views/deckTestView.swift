//
//  deckTestView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI

struct deckTestView: View {
    @Binding var presented: Bool
    
    var body: some View {
        Text("")
    }
}

struct deckTestView_Previews: PreviewProvider {
    static var previews: some View {
        deckTestView(presented: .constant(false))
    }
}
