//
//  deckCreationView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/23/22.
//

import SwiftUI
import Foundation
import Vision

// Create a Deck
struct deckCreation: View {
    var width: CGFloat = 450
    var height: CGFloat = 250
    
    private var padding: CGFloat = 7.0

    @State private var deckTitle: String = ""
    @State private var deckCards: [card] = []
        
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: true) {
                // Title Card
                titleCardEdit(text: self.$deckTitle, width: self.width, height: self.height)
                    .padding(.horizontal)
                    .padding(.vertical, self.padding)
                
                // Cards
                ForEachIndexed(self.$deckCards) { index, bind in
                    normalCardEdit(cardArr: self.$deckCards, card: bind, width: self.width, height: self.height)
                        .padding(.horizontal)
                        .padding(.vertical, self.padding)
                }
                
                // Spacer
                Rectangle()
                    .foregroundColor(Color.clear)
                    .frame(width: geo.size.width - 14, height: CGFloat(geo.size.height - CGFloat((self.height + CGFloat(2 * self.padding)) * CGFloat(self.deckCards.count + 1)) - 60 - 20))

                // Add Card
                addCardEdit(width: self.width, height: self.height)
                    .padding(.horizontal)
                    .padding(.vertical, self.padding)
                    .frame(height: 60, alignment: .top)
                    .onTapGesture {
                        let newCard = card(front: "", back: "")
                        self.deckCards.append(newCard)
                    }
            }
            .frame(width: geo.size.width)
        }
    }
}

struct deckCreation_Previews: PreviewProvider {
    static var previews: some View {
        deckCreation()
    }
}


// Title Card Edit View
struct titleCardEdit: View {
    @Binding var text : String
    
    var width: CGFloat = 450
    var height: CGFloat = 250
    
    var body: some View {
        ZStack {
            cardBkg()
            
            CustomTextEditor(text: self.$text, placeholder: "Deck Title")
                .padding()

        }
        .frame(width: self.width, height: self.height)
        .accessibility(addTraits: .isButton)
    }
}

// Normal Card Edit View
struct normalCardEdit: View {
    @Binding var cardArr: [card]
    @Binding var card: card
    
    var width: CGFloat = 450
    var height: CGFloat = 250
       
    // Edit variables
    @State private var isFlipped = false
    @State private var cameraBtnHover = false
    @State private var trashBtnHover = false
    @State private var backBtnHover = false
    
    var body: some View {
        ZStack {
            cardBkg()
            
            if !self.isFlipped {
                CustomTextEditor(text: self.$card.front, placeholder: "Front", fontSize: 20.0)
                    .padding()
                    .animation(.none)
            } else {
                CustomTextEditor(text: self.$card.back, placeholder: "Back", fontSize: 20.0)
                    .padding()
                    .rotation3DEffect(.degrees(self.isFlipped ? 180 : 0), axis: (x: -1, y: 0, z: 0))
                    .animation(.none)
            }
            
            // Edit Options
            VStack(alignment: .center) {
                HStack(alignment: .top) {
                    Spacer()
                    
                    HStack(alignment: .top) {
                        if self.cameraBtnHover {
                            Text("Insert Text")
                        }
                        
                        Image(systemName: "camera.fill")
                            .frame(width: 15, height: 15, alignment: .center)
                            .foregroundColor(.black)
                    }
                    .onHover { hover in
                        self.cameraBtnHover = hover
                    }
                }
                .onTapGesture {  filePicker() }
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    HStack(alignment: .bottom) {
                        Image(systemName: "trash.fill")
                            .frame(width: 15, height: 15, alignment: .center)
                            .foregroundColor(.red)
                        
                        if self.trashBtnHover {
                            Text("Remove Card")
                        }
                    }
                    .onHover { hover in
                        self.trashBtnHover = hover
                    }
                    .onTapGesture {
                        if let index = self.cardArr.firstIndex(of: self.card) {
                            self.cardArr.remove(at: index)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        if self.backBtnHover {
                            Text(self.isFlipped ? "Edit Front" : "Edit Back")
                        }
                        
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .frame(width: 15, height: 15, alignment: .center)
                            .foregroundColor(.black)
                    }
                    .onHover { hover in
                        self.backBtnHover = hover
                    }
                    .onTapGesture { self.isFlipped.toggle() }
                }
            }
            .padding(14)
            .frame(width: self.width, height: self.height)
            .rotation3DEffect(.degrees(self.isFlipped ? 180 : 0), axis: (x: -1, y: 0, z: 0))
        }
        .frame(width: self.width, height: self.height)
        .accessibility(addTraits: .isButton)
        .rotation3DEffect(.degrees(self.isFlipped ? 180 : 0), axis: (x: -1, y: 0, z: 0))
        .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
    
    private func filePicker() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select photo"
        openPanel.worksWhenModal = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["png","jpg","jpeg"]
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                // Load image
                let image = NSImage(contentsOfFile: openPanel.url!.path)!
                if image.size.width == 0 {
                    return
                }
                
                // Setup live text request
                let request = VNRecognizeTextRequest { (request, error) in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                    
                    var ocrText = ""
                    for observation in observations {
                        guard let topCandidate = observation.topCandidates(1).first else { continue }
                        ocrText += topCandidate.string + " "
                    }
                    
                    DispatchQueue.main.async {
                        if !self.isFlipped {
                            self.card.front = self.card.front + ocrText
                        } else {
                            self.card.back = self.card.back + ocrText
                        }
                    }
                }
                request.recognitionLevel = .accurate
                request.recognitionLanguages = ["en-US"]
                request.usesLanguageCorrection = true
                
                // Do request
                DispatchQueue.main.async {
                    let requestHandler = VNImageRequestHandler(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, options: [:])
                    do {
                        try requestHandler.perform([request])
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

// Add Card View
struct addCardEdit: View {
    var width: CGFloat = 450
    var height: CGFloat = 250
    @State private var isHover = false
    
    var body: some View {
        ZStack(alignment: .top) {
            cardBkg()
            
            Text("Add Card")
                .font(.title)
                .foregroundColor(Color.blue)
                .offset(x: 0, y: 15)
                
        }
        .frame(width: self.width, height: self.height)
        .accessibility(addTraits: .isButton)
        .onHover { hover in
            isHover = hover
        }
        .animation(.spring())
        .offset(x: 0, y: isHover ? -10 : 0)
        .scaleEffect(isHover ? 1.01 : 1)
    }
}


// Custom Text Editor
struct CustomTextEditor: View {
    @Binding var text: String
    var placeholder: String = ""
    @State var fontSize: CGFloat
    @State private var textEditorHeight: CGFloat

    init(text: Binding<String>, placeholder: String = "", fontSize: CGFloat = 40.0) {
        self._text = text
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.textEditorHeight = fontSize + 17
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ZStack() {
                if (self.text.isEmpty) {
                    Text(self.placeholder)
                        .font(.system(size: self.fontSize))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(5)
                        .offset(x: 0, y: 0)
                        .multilineTextAlignment(.center)
                }
                TextEditor(text: self.$text)
                    .font(.system(size: self.fontSize))
                    .foregroundColor(Color.black.opacity(1))
                    .padding(5)
                    .offset(x: 8, y: 0)
                    .multilineTextAlignment(.center)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: self.text, perform: {_ in
                                    self.textEditorHeight = geo.size.height
                                })
                        }
                    )
                    .overlay(coverScrollOverlay, alignment: .trailing)
            }
        }
        .frame(height: min(self.textEditorHeight, 200))
    }
    
    private var coverScrollOverlay: some View {
        Rectangle()
            .frame(width: 20)
            .foregroundColor(Color.white)
    }
}
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}

// Custom ForEach with Binding
struct ForEachIndexed<Data: MutableCollection&RandomAccessCollection, RowContent: View, ID: Hashable>: View, DynamicViewContent where Data.Index : Hashable
{
    var data: [(Data.Index, Data.Element)] {
        forEach.data
    }
    
    let forEach: ForEach<[(Data.Index, Data.Element)], ID, RowContent>
    
    init(_ data: Binding<Data>,
         @ViewBuilder rowContent: @escaping (Data.Index, Binding<Data.Element>) -> RowContent
    ) where Data.Element: Identifiable, Data.Element.ID == ID {
        forEach = ForEach(
            Array(zip(data.wrappedValue.indices, data.wrappedValue)),
            id: \.1.id
        ) { i, _ in
            rowContent(i, Binding(get: { data.wrappedValue[i] }, set: { data.wrappedValue[i] = $0 }))
        }
    }
    
    init(_ data: Binding<Data>,
         id: KeyPath<Data.Element, ID>,
         @ViewBuilder rowContent: @escaping (Data.Index, Binding<Data.Element>) -> RowContent
    ) {
        forEach = ForEach(
            Array(zip(data.wrappedValue.indices, data.wrappedValue)),
            id: (\.1 as KeyPath<(Data.Index, Data.Element), Data.Element>).appending(path: id)
        ) { i, _ in
            rowContent(i, Binding(get: { data.wrappedValue[i] }, set: { data.wrappedValue[i] = $0 }))
        }
    }
    
    var body: some View {
        forEach
    }
}
