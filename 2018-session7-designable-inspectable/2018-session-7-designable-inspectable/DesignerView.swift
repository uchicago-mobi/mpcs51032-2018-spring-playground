//
//  DesignerView.swift
//  2017-PerformaceWithInstruments
//
//  Created by T. Andrew Binkowski on 5/20/17.
//  Copyright © 2017 T. Andrew Binkowski. All rights reserved.
//

import UIKit

@IBDesignable

class DesignerView: UIView {
  @IBInspectable public var color: UIColor = UIColor.clear {
    didSet {
      self.backgroundColor = color
    }
  }
  
  @IBInspectable var borderColor: UIColor = UIColor.white {
    didSet {
      self.layer.borderColor = borderColor.cgColor
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 1.0 {
    didSet {
      self.layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable
  public var cornerRadius: CGFloat = 2.0 {
    didSet {
      self.layer.cornerRadius =  cornerRadius
    }
  }
  
}


@IBDesignable
class RoundImageView: UIImageView {
  
  @IBInspectable public var rounded: Bool = false {
    didSet {
      if rounded {
        self.layer.cornerRadius = 10
      } else {
        self.layer.cornerRadius = 0
      }
      self.setNeedsDisplay()
    }
  }
  
  
}




