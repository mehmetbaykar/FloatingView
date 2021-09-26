import UIKit

public class FloatingWindowManager {
    private var floatingWindow: FloatingWindow?
    
    public static let shared = FloatingWindowManager()
    
    public func makeFloatingWindowKeyAndVisible(statusBarStyle: UIStatusBarStyle = .default,
                                         viewController:FloatableViewController) {
        
        defer {
            FloatingWindowManager.shared.floatingWindow?.makeKeyAndVisible()
        }
        guard FloatingWindowManager.shared.floatingWindow == nil else { return }
        
        let floatingWindow = FloatingWindow(frame: UIScreen.main.bounds,
                                            statusBarStyle: statusBarStyle,
                                            viewController: viewController)
        FloatingWindowManager.shared.floatingWindow = floatingWindow
    }
    
    
   public  func resignFloatingWindowKey() {
        FloatingWindowManager.shared.floatingWindow?.resignWindow()
        FloatingWindowManager.shared.floatingWindow = nil
    }
    
   public func updateFloatingWindowStatusBarStyle(to style: UIStatusBarStyle) {
        FloatingWindowManager.shared.floatingWindow?.statusBarStyle = style
    }
}
