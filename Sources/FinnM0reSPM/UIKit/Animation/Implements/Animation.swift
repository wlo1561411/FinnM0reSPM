import UIKit

protocol Animation: NSObject, CAAnimationDelegate {
    var onCompleted: ((_ success: Bool) -> Void)? { get }
    func perform()
}

extension Animation {
    func createBasicAnimation(
        keyPath: String,
        fromValue: Any,
        toValue: Any,
        duration: CFTimeInterval)
        -> CABasicAnimation
    {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        return animation
    }
}

/// Only for override, should not use as Type
class BaseAnimation: NSObject, Animation {
    private(set) var nextAnimation: Animation?

    weak var layer: CALayer?

    var onCompleted: ((Bool) -> Void)?

    let fromValue: Any
    let toValue: Any
    let duration: CFTimeInterval

    init(
        fromValue: Any,
        toValue: Any,
        duration: CFTimeInterval,
        nextAnimation: Animation? = nil,
        layer: CALayer? = nil,
        onCompleted: ((Bool) -> Void)? = nil)
    {
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.nextAnimation = nextAnimation
        self.layer = layer
        self.onCompleted = onCompleted
    }

    func perform() { }
}

// MARK: - Chaining

extension BaseAnimation {
    @discardableResult
    func onCompleted(_ completion: @escaping (Bool) -> Void) -> Self {
        onCompleted = completion
        return self
    }

    @discardableResult
    func nextAnimation(_ animation: Animation) -> Self {
        nextAnimation = animation
        return self
    }
}

// MARK: - CAAnimationDelegate

extension BaseAnimation: CAAnimationDelegate {
    func animationDidStop(_: CAAnimation, finished flag: Bool) {
        onCompleted?(flag)

        if flag {
            nextAnimation?.perform()
        }
    }
}
