//
//  ViewController.swift
//  2018-session4-vision
//
//  Created by T. Andrew Binkowski on 4/22/18.
//  Copyright © 2018 T. Andrew Binkowski. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var textView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // The images in asset catalog
    let images = ["dog","swim","cat","pro","apple"]
    
    // Grab a random one
    let randomIndex = Int(arc4random_uniform(UInt32(images.count)))
    let image = UIImage(named: images[randomIndex] )
    imageView.image = image
    
    // Convert to CIImage (CoreImage)
    guard let ciImage = CIImage(image: image!) else {
      fatalError("Not able to convert UIImage to CIImage")
    }

    detectObjects(image: ciImage)
  }

  
  
  func detectObjects(image: CIImage) {

    // Load the ML model through its generated class
    guard let model = try? VNCoreMLModel(for: MobileNet().model) else {
      fatalError("Can't load the ML model")
    }
    
    // Create a Vision request with completion handler
    let request = VNCoreMLRequest(model: model) { request, error in
      
      guard let results = request.results as? [VNClassificationObservation] else {
          fatalError("Unexpected result type from VNCoreMLRequest")
      }
      
      // Put the top 5 into a string to show on the screen
      var tags = ""
      for result in results[0...5] {
        tags += "🤔 \(result.identifier) (\(Int(result.confidence * 100))%)\n"
      }
      
      // Update UI on main queue
      DispatchQueue.main.async {
         self.textView.text = tags
      }
    }
    
    // Run the Core ML model classifier on global dispatch queue
    let handler = VNImageRequestHandler(ciImage: image)
    DispatchQueue.global(qos: .userInteractive).async {
      do {
        try handler.perform([request])
      } catch {
        print(error)
      }
    }
  }
  


}

