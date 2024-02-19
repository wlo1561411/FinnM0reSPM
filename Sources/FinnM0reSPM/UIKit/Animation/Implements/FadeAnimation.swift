import UIKit

final class FadeAnimation: BaseAnimation {
    init(
        fromValue: CGFloat = 1,
        toValue: CGFloat = 0,
        duration: CFTimeInterval = 0.15,
        layer: CALayer? = nil)
    {
        super.init(
            fromValue: fromValue,
            toValue: toValue,
            duration: duration,
            layer: layer)
    }

    private func startAnimation(reverse: Bool) {
        let opacity = createBasicAnimation(
            keyPath: "opacity",
            fromValue: reverse ? toValue : fromValue,
            toValue: reverse ? fromValue : toValue,
            duration: duration)

        layer?.add(opacity, forKey: "opacity")
    }

    override func perform() {
        startAnimation(reverse: false)
    }
}
