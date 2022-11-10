//import UIKit
//
//public protocol ComponentStyle {
//    var attributes: [StyleAttribute] { get }
//}
//
//public enum StyleAttribute {
//    case backgroundColor(controlState: UIControl.State?, color: UIColor)
//    case borderColor(color: UIColor)
//    case borderWidth(width: CGFloat)
//    case dottedBorder(color: UIColor)
//    case cornerRadius(_: CGFloat)
//    case font(_: UIFont?)
//    case textColor(controlState: UIControl.State?, color: UIColor)
//    
//    case padding(left: CGFloat, right: CGFloat)
//    case paddingView(left: UIView?, right: UIView?)
//    case placeholder(color: UIColor, text: String)
//}
//
//extension Array where Element == StyleAttribute {
//    func addAttribute(_ attribute: StyleAttribute) -> [StyleAttribute] {
//        var array = self
//        array.append(attribute)
//        return array
//    }
//
//    func backgroundColor(controlState: UIControl.State, color: UIColor) -> [StyleAttribute] {
//        addAttribute(.backgroundColor(controlState: controlState, color: color))
//    }
//
//    func borderColor(_ color: UIColor) -> [StyleAttribute] {
//        addAttribute(.borderColor(color: color))
//    }
//
//    func borderWidth(_ width: CGFloat) -> [StyleAttribute] {
//        addAttribute(.borderWidth(width: width))
//    }
//
//    func cornerRadius(_ cornerRadius: CGFloat) -> [StyleAttribute] {
//        addAttribute(.cornerRadius(cornerRadius))
//    }
//
//    func font(_ font: UIFont?) -> [StyleAttribute] {
//        guard let font = font else { return self }
//        return addAttribute(.font(font))
//    }
//
//    func textColor(controlState: UIControl.State?, color: UIColor) -> [StyleAttribute] {
//        addAttribute(.textColor(controlState: controlState, color: color))
//    }
//    
//    func placeholder(color: UIColor, text: String) -> [StyleAttribute]  {
//        addAttribute(.placeholder(color: color, text: text))
//    }
//    
//    func padding(left: CGFloat, right: CGFloat) -> [StyleAttribute] {
//        addAttribute(.padding(left: left, right: right))
//    }
//    
//    func paddingView(left: UIView?, right: UIView?) -> [StyleAttribute] {
//        addAttribute(.paddingView(left: left, right: right))
//    }
//    
//    func dottedBorder(color: UIColor) -> [StyleAttribute] {
//        addAttribute(.dottedBorder(color: color))
//    }
//}
//
