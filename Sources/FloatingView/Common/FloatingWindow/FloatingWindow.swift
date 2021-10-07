import UIKit
import WebKit

class FloatingWindow: UIWindow {
    
    private  weak var floatingWindowRootViewController: FloatableViewController?
    private  var pointInsideCalled : Bool = true
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.floatingWindowRootViewController?.statusBarStyle = statusBarStyle
            UIView.animate(withDuration: 0.35) {
                self.floatingWindowRootViewController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    deinit{
        print("\(self.debugDescription) has been denited")
    }
    
    init(frame: CGRect,
         statusBarStyle: UIStatusBarStyle,
         viewController:FloatableViewController) {
        
        self.floatingWindowRootViewController = viewController
        self.statusBarStyle = statusBarStyle
        
        super.init(frame: frame)
        self.rootViewController = floatingWindowRootViewController
   
        self.addSubview(viewController.floatingView)
        self.bringSubviewToFront(viewController.floatingView)
        
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        for subView in subviews {
            if subView is WKWebView {
                return subView.hitTest(self.convert(point, to: subView), with: event) != nil
            }
        }
        return false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            self.pointInsideCalled = true
            return floatingWindowRootViewController?.floatingView
        }
        if pointInsideCalled {
            self.pointInsideCalled = false
            return  floatingWindowRootViewController?.floatingView
        }
        return nil
    }
    
    
    func resignWindow(){
        self.floatingWindowRootViewController?.floatingView.floatingDelegate = nil
        self.floatingWindowRootViewController = nil
        self.rootViewController = nil
    }
}
