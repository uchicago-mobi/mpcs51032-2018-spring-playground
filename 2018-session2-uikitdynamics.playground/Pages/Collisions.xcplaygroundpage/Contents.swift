//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

func randomColor() -> UIColor {
  let hue : CGFloat = CGFloat(arc4random() % 256) / 256
  let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
  let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
  return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
}

///
///
///
class MyViewController : UIViewController {

  var animator:UIDynamicAnimator? = nil;
//  let gravity = UIGravityBehavior()
//  let itemBehavior = UIDynamicItemBehavior()
  
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .white
    self.view = view
    play()
  }
  
  
  func play() {
    
    var squares = [UIView]()

    for _ in 0...20 {
      let square = makeSquare()
      squares.append(square)
      self.view.addSubview(square)
    }
    
    self.animator = UIDynamicAnimator(referenceView: self.view)

    let gravity = UIGravityBehavior(items: squares)
    gravity.gravityDirection = CGVector(dx: 0, dy: 0.8)
    animator?.addBehavior(gravity)

    let itemBehavior = UIDynamicItemBehavior(items: squares)
    itemBehavior.friction = 0.1;
    itemBehavior.elasticity = 0.9
    animator?.addBehavior(itemBehavior)
    
    
    ///
    let barrier = UIView(frame: CGRect(x: 0, y: 300, width: 110, height: 20))
    barrier.backgroundColor = UIColor.red
    self.view.addSubview(barrier)
    
    ///
    let collision = UICollisionBehavior(items: squares)
    collision.translatesReferenceBoundsIntoBoundary = true
    animator?.addBehavior(collision)
    
    let rightEdge = CGPoint(x: barrier.frame.origin.x + barrier.frame.size.width,
                            y: barrier.frame.origin.y)
    collision.addBoundary(withIdentifier: "barrier" as NSCopying,
                          from: barrier.frame.origin, to: rightEdge)
  }
  
  
  ///
  func makeSquare() -> UIView {
    let square = UIView(frame: CGRect(x: 100, y: 100,
                                      width: 40, height: 40))
    square.backgroundColor = randomColor()
    return square
  }
  
  
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
PlaygroundPage.current.needsIndefiniteExecution = true

