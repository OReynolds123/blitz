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
    var width: CGFloat
    @Binding var saveBtn: Bool
    
    private var padding: CGFloat = 7.0

    @State private var deckTitle: String = ""
    @State private var deckCards: [card] = []
    
    @State private var scrollIndex: Int?
    
    @State private var addCardPress: Bool = false
    @State private var height: CGFloat
    
    init(width: CGFloat = 450, saveBtn: Binding<Bool>) {
        self.width = width
        self.height = self.width * (3/5)
        self._saveBtn = saveBtn
    }
        
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Label(deckTitle == "" ? "Deck Title" : deckTitle, systemImage: "home")
                        .onTapGesture {
                            self.scrollIndex = 0
                        }

                    ForEachIndexed(self.$deckCards) { index, elem in
                        Label(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front, systemImage: "")
                            .onTapGesture {
                                self.scrollIndex = index + 1
                            }
                    }

                    Label("New Card", systemImage: "")
                        .onTapGesture {
                            self.deckCards.append(card(front: "", back: ""))
                        }
                }

                Spacer()

                Label("Cancel", systemImage: "")
                    .foregroundColor(.red)
                    .onTapGesture {
                        self.saveBtn.toggle()
                    }
                    
                Label("Save", systemImage: "")
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)
                    .onTapGesture {
                        self.saveBtn.toggle()
                    }
            }

            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: true) {
                    ScrollViewReader { (proxy: ScrollViewProxy) in
                        // Title Card
                        titleCardEdit(text: self.$deckTitle, width: self.width)
                            .padding(.horizontal)
                            .padding(.vertical, self.padding)
                            .padding(.top, 20)
                            .id(0)

                        // Cards
                        ForEachIndexed(self.$deckCards) { index, bind in
                            normalCardEdit(cardArr: self.$deckCards, card: bind, width: self.width)
                                .padding(.horizontal)
                                .padding(.vertical, self.padding)
                                .id(index + 1)
                        }
                        .onChange(of: self.scrollIndex) { target in
                            if let target = target {
                                self.scrollIndex = nil
                                withAnimation {
                                    proxy.scrollTo(target, anchor: .center)
                                }
                            }
                        }

                        // Spacer
                        Rectangle()
                            .foregroundColor(Color.clear)
                            .frame(width: geo.size.width - 14, height: CGFloat(geo.size.height - CGFloat((self.height + CGFloat(2 * self.padding) + 8) * CGFloat(self.deckCards.count + 1)) - 60 - 35))

                        // Add Card
                        addCardEdit(width: self.width, press: self.$addCardPress)
                            .padding(.horizontal)
                            .padding(.vertical, self.padding)
                            .frame(height: 60, alignment: .top)
                            .onChange(of: self.addCardPress) { _pressed in
                                self.deckCards.append(card(front: "", back: ""))
                            }
                    }
                }
                .frame(width: geo.size.width)
            }
        }
    }
}

struct deckCreation_Previews: PreviewProvider {
    static var previews: some View {
        deckCreation(saveBtn: .constant(true))
    }
}


// Title Card Edit View
struct titleCardEdit: View {
    @Binding var text : String
    var width: CGFloat = 450
    
    @State private var press: Bool = false
    @State private var hover: Bool = false
    
    var body: some View {
        let elem = AnyView(
            CustomTextEditor(text: self.$text, placeholder: "Deck Title")
                .padding()
        )
        cardView_noFlip(elem: elem, width: self.width, press: self.$press, hover: self.$hover)
    }
}

// Normal Card Edit View
struct normalCardEdit: View {
    @Binding var cardArr: [card]
    @Binding var card: card
    var width: CGFloat = 450
    
    @State private var press: Bool = false
    @State private var hover: Bool = false
    
    @State private var cameraBtnHover = false
    @State private var trashBtnHover = false
    @State private var backBtnHover = false
    
    var body: some View {
        let elem = AnyView(
            ZStack {
                if !self.press {
                    CustomTextEditor(text: self.$card.front, placeholder: "Front", fontSize: 20.0)
                        .padding()
                        .animation(.none)
                } else {
                    CustomTextEditor(text: self.$card.back, placeholder: "Back", fontSize: 20.0)
                        .padding()
                        .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
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
                                Text(self.press ? "Edit Front" : "Edit Back")
                            }
                            
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .frame(width: 15, height: 15, alignment: .center)
                                .foregroundColor(.black)
                        }
                        .onHover { hover in
                            self.backBtnHover = hover
                        }
                        .onTapGesture { self.press.toggle() }
                    }
                }
                .padding(14)
                .frame(width: self.width)
                .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
            }
        )
        cardView_noBindings(elem: elem, width: self.width, press: self.$press, hover: self.$hover)
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
                        if !self.press {
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
    @Binding var press: Bool
    
    @State private var hover: Bool = false
    
    var body: some View {
        let elem = AnyView(
            Text("Add Card")
                .font(.title)
                .foregroundColor(Color.blue)
                .offset(x: 0, y: -(self.width / 4))
        )
        cardView_button(elem: elem, width: self.width, press: self.$press, hover: self.$hover)
    }
}


// Custom Text Editor
struct CustomTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var fontSize: CGFloat
    var height: CGFloat
    
    @State private var textEditorHeight: CGFloat

    init(text: Binding<String>, placeholder: String = "", fontSize: CGFloat = 40.0, height: CGFloat = 250) {
        self._text = text
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.textEditorHeight = fontSize + 17
        self.height = height - 75
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
        .frame(height: min(self.textEditorHeight, self.height))
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
