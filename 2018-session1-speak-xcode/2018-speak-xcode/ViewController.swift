//
//  ViewController.swift
//  2018-speak-xcode
//
//  Created by T. Andrew Binkowski on 4/4/18.
//  Copyright © 2018 T. Andrew Binkowski. All rights reserved.
//

import UIKit
import AVFoundation

let string = "One fish Two fish Red fish Blue fish. Black fish Blue fish Old fish New; fish. This one has a little star. This one has a little car. Say! What a lot of fish there are."

class ViewController: UIViewController {
  let synthesizer = AVSpeechSynthesizer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    speakDemo()
  }
}

extension ViewController {

  func speakDemo() {
    synthesizer.delegate = self
    let voice = AVSpeechSynthesisVoice(language: "en_US")
    let utterance = AVSpeechUtterance(string: string)
    utterance.voice = voice
    utterance.pitchMultiplier = 1.0
    utterance.rate = 0.25
    synthesizer.speak(utterance)
  }
  
  
}

extension ViewController: AVSpeechSynthesizerDelegate {
  
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                         didStart utterance: AVSpeechUtterance) {
    print("🤖 Start Speaking")
  }
  
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                         willSpeakRangeOfSpeechString characterRange: NSRange,
                         utterance: AVSpeechUtterance) {
    print("📣: \(characterRange.location) - \(characterRange.length+characterRange.location)")
  }
}


