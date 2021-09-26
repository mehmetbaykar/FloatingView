import UIKit

public protocol FloatableViewController:UIViewController {
    var statusBarStyle: UIStatusBarStyle { get set }
    var floatingView: FloatingView {get set}
}
