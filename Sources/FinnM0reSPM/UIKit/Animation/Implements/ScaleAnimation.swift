import UIKit

final class ScaleAnimation: BaseAnimation {
    enum Style {
        /// Follow fromValue and toValue
        case normal
        /// Will auto reverse
        case reverse
    }

    private var style: Style = .reverse
    private var onScaleDown: (() -> Void)?

    init(
        fromValue: CGFloat = 1,
        toValue: CGFloat = 0.5,
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
        let reverseFrom = reverse ? toValue : fromValue
        let reverseTo = reverse ? fromValue : toValue

        let scaleDown = createBasicAnimation(
            keyPath: "transform.scale",
            fromValue: style == .normal ? fromValue : reverseFrom,
            toValue: style == .normal ? toValue : reverseTo,
            duration: duration)

        layer?.add(scaleDown, forKey: "transform.scale.down")
    }

    override func perform() {
        startAnimation(reverse: false)
    }

    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard
            flag,
            let animation = anim as? CABasicAnimation
        else {
            onCompleted?(flag) // If animating and remove all animation the flag will be false
            return
        }

        let isScaleDown = (animation.fromValue as? CGFloat ?? 0) > (animation.toValue as? CGFloat ?? 0)

        switch style {
        case .normal:
            if isScaleDown {
                onScaleDown?()
            }

            onCompleted?(flag)
            nextAnimation?.perform()

        case .reverse:
            if isScaleDown {
                onScaleDown?()
                startAnimation(reverse: true)
            }
            else {
                onCompleted?(flag)
                nextAnimation?.perform()
            }
        }
    }

    @discardableResult
    func style(_ style: Style) -> Self {
        self.style = style
        return self
    }

    @discardableResult
    func onScaleDown(_ onScaleDown: (() -> Void)?) -> Self {
        self.onScaleDown = onScaleDown
        return self
    }
}
