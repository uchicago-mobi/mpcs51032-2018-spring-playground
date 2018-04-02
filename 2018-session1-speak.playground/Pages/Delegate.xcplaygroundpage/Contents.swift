import UIKit
import PlaygroundSupport
import AVFoundation
PlaygroundPage.current.needsIndefiniteExecution = true


let string = "One fish Two fish Red fish Blue fish. Black fish Blue fish Old fish New; fish. This one has a little star. This one has a little car. Say! What a lot of fish there are."

class PlaygroundViewController: UIViewController {
  let synthesizer = AVSpeechSynthesizer()
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    synthesizer.delegate = self
    let voice = AVSpeechSynthesisVoice(language: "en_US")
    let utterance = AVSpeechUtterance(string: string)
    utterance.voice = voice
    utterance.pitchMultiplier = 1.0
    utterance.rate = 0.25
    synthesizer.speak(utterance)
  }
}

///
///
///
extension PlaygroundViewController: AVSpeechSynthesizerDelegate {
  
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                         didStart utterance: AVSpeechUtterance) {
    print("Started")
  }
  
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                         willSpeakRangeOfSpeechString characterRange: NSRange,
                         utterance: AVSpeechUtterance) {
    print("📣: \(characterRange.location) - \(characterRange.length+characterRange.location)")
  }
}

// Create an instance of the view controller
let viewController = PlaygroundViewController()

