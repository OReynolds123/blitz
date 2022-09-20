//
//  alphaDemo.swift
//  Alpha_macOS
//
//  Created by Capstone on 9/12/22.
//

import SwiftUI
import Vision

struct alpha: View {
    @State private var image = NSImage()
    @State private var imagePath = ""
    @State private var scanText = "Extracted text..."
    @State private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    
    var body: some View {
        VStack {
            Image(nsImage: self.image)
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 300)
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    Text(self.image.size.width == 0 ? "Choose Photo" : "")
                        .font(.headline)
                        .foregroundColor(.white)
                )
                .onTapGesture {
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
                            self.imagePath = openPanel.url!.path
                            self.image = NSImage(contentsOfFile: self.imagePath)!
                        }
                    }
                }
            
            Button("Scan", action: doScan)
                .buttonStyle(DefaultButtonStyle())
            
            TextEditor(text: self.$scanText)
                .padding(8)
                .foregroundColor(.gray)
                .font(.system(.body, design: .monospaced))
                .frame(width: 400, height: 200)
                .cornerRadius(10)
        }
        .padding(20)
    }
    
    
    func doScan() {
        configureOCR()
        processImage()
    }
    
    func processImage() {
        if self.image.size.width == 0 {
            self.scanText = "You must select an image!"
            return
        } else {
            self.scanText = ""
        }
        let requestHandler = VNImageRequestHandler(cgImage: self.image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, options: [:])
        //let requestHandler = VNImageRequestHandler(cgImage: self.image.cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    func configureOCR() {
        self.ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                ocrText += topCandidate.string + "\n"
            }
            
            DispatchQueue.main.async {
                self.scanText = ocrText
            }
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US"]
        ocrRequest.usesLanguageCorrection = true
    }
}

struct alphaDemo_Previews: PreviewProvider {
    static var previews: some View {
        alpha()
    }
}
