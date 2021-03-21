import UIKit

public protocol RBActivityLoader: class {
  func startAnimating(activityColor: UIColor,
                      backgroundColor: UIColor,
                      alpha: CGFloat)
  func stopAnimating()
}

public extension RBActivityLoader where Self: UIViewController {
 
  func startAnimating(activityColor: UIColor = .blue,
                      backgroundColor: UIColor = .white,
                      alpha: CGFloat = 0.45) {
    let activityView = UIView(frame: UIScreen.main.bounds)
    activityView.backgroundColor = backgroundColor
    activityView.alpha = alpha
    activityView.tag = 4444
    view.addSubview(activityView)
    
    let activity = ActivityIndicatorView(style: .large)
    activity.tag = 4443
    activity.center = activityView.convert(activityView.center, from: activityView.superview)
    activity.color = activityColor
    activity.startAnimating()
    view.addSubview(activity)
  }
  
  func stopAnimating() {
    view.subviews
      .filter { $0.tag == 4444 || $0.tag == 4443 }
      .forEach { $0.removeFromSuperview() }
  }
  
}

open class ActivityIndicatorView: UIView {
  public enum ActivityIndicatorViewStyle: Int {
    case small
    case large
    case `default`
  }
  
  public var color: UIColor {
    didSet {
      self.shapeLayer.strokeColor = color.cgColor
    }
  }
  
  public var isAnimating: Bool {
    get {
      return _isAnimating
    }
    set(value) {
      _isAnimating = value
    }
  }
  
  private var _isAnimating: Bool = false
  
  public var style: ActivityIndicatorViewStyle
  public var hidesWhenStopped: Bool = true
  public var duration: CGFloat
  
  private var shapeLayer: CAShapeLayer
  private var contentView: UIView
  
  
  public init(style: ActivityIndicatorViewStyle = .default) {
    var frame: CGRect!
    var lineWidth: CGFloat!
    var duration: CGFloat!
    
    self.style = style
    switch style {
    case .small:
      frame = CGRect(x: 0, y: 0, width: 20, height: 20)
      lineWidth = 2.0
      duration = 0.8
    case .default:
      frame = CGRect(x: 0, y: 0, width: 30, height: 30)
      lineWidth = 4.0
      duration = 0.8
    case .large:
      frame = CGRect(x: 0, y: 0, width: 60, height: 60)
      lineWidth = 8.0
      duration = 1
      
    }
    color = .lightGray
    
    
    contentView = UIView(frame: frame)
    shapeLayer = CAShapeLayer()
    self.duration = duration
    
    super.init(frame: frame)
    
    commonInit(lineWidth: lineWidth, duration: duration)
  }
  
  public init(frame: CGRect, lineWidth: CGFloat, duration: CGFloat) {
    color = .lightGray
    self.duration = duration
    style = .default
    shapeLayer = CAShapeLayer()
    contentView = UIView(frame: frame)
    
    super.init(frame: frame)
  
    commonInit(lineWidth: lineWidth, duration: duration)
  }
  
  private func commonInit(lineWidth: CGFloat, duration: CGFloat) {
    
    addSubview(contentView)
    
    let radius = frame.size.width / 2
    shapeLayer = CAShapeLayer(layer: layer)
    shapeLayer.frame = bounds
    shapeLayer.lineWidth = lineWidth
    shapeLayer.fillColor = UIColor.clear.cgColor
    
    let bezierPathFrame = CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius)
    let bezierPath = UIBezierPath(roundedRect: bezierPathFrame, cornerRadius: radius)
    shapeLayer.path = bezierPath.cgPath
    shapeLayer.lineCap = .round
    shapeLayer.isHidden = true
    contentView.layer.insertSublayer(shapeLayer, at: 0)
    hidesWhenStopped = true
  }
  
  required public init?(coder aDecoder: NSCoder) {
    
    color = .lightGray
    contentView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    shapeLayer = CAShapeLayer()
    style = .large
    duration = 1
    super.init(coder: aDecoder)
  }
  
  public func startAnimating() {
    guard !isAnimating else { return }
    
    isAnimating = true
    
    let inAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
    inAnimation.duration = CFTimeInterval(duration)
    inAnimation.values = [0, 1]
    
    let outAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
    outAnimation.duration = CFTimeInterval(duration)
    outAnimation.values = [0, 0.8, 1]
    outAnimation.beginTime = CFTimeInterval(duration / 1.5)
    
    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [inAnimation, outAnimation]
    groupAnimation.duration = Double(self.duration) + outAnimation.beginTime
    groupAnimation.repeatCount = .infinity;
    
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    rotationAnimation.fromValue = 0
    rotationAnimation.toValue = Double.pi * 2
    rotationAnimation.duration = CFTimeInterval(duration * 1.5)
    rotationAnimation.repeatCount = .infinity
    
    shapeLayer.add(rotationAnimation, forKey: nil)
    shapeLayer.add(groupAnimation, forKey: nil)
    
    shapeLayer.isHidden = false
  }
  
  public func stopAnimating() {
    UIView.animate(withDuration: 0.1) {
      self.contentView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      self.contentView.alpha = 0
    } completion: { _ in
      self.isAnimating = false
      self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
      self.contentView.alpha = 0
      self.shapeLayer.isHidden = self.hidesWhenStopped
      self.shapeLayer.removeAllAnimations()
    }
  }
}
