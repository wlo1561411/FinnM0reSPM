import UIKit

final class ScaleAnimator {
    private weak var view: UIView?

    private var animation: Animation?

    private var isOn = false

    init(view: UIView) {
        self.view = view
    }

    func start(isOn: Bool = true) {
        guard isOn != self.isOn else { return }

        self.isOn = isOn

        removeLayerAnimations()
        setupAnimation()
        animation?.perform()
    }
}

// MARK: - UI

extension ScaleAnimator {
    func removeLayerAnimations() {
        view?.layer.removeAllAnimations()
    }

    private func setupAnimation() {
        animation = ScaleAnimation(
            fromValue: isOn ? 1 : 0.5,
            toValue: isOn ? 0.5 : 1,
            layer: view?.layer)
            .style(.normal)
    }
}
