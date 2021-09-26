import UIKit

extension UIEdgeInsets{
     static let `default`:UIEdgeInsets = {
        guard let window = UIApplication.shared.windows.last
        else { return UIEdgeInsets.zero}
        
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        
        return UIEdgeInsets(top: topPadding, left: .zero, bottom: bottomPadding, right: .zero)
    }()
}
