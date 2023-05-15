import UIKit

final class FavorAnimator {
    private weak var imageView: UIImageView?
    private weak var fullImageView: UIImageView?

    private var animation: Animation?

    private let shouldFadeOut: Bool

    private var isOn = false

    private var onScaleDown: (() -> Void)?
    private var onCompleted: (() -> Void)?

    init(
        imageView: UIImageView,
        fullImageView: UIImageView,
        shouldFadeOut: Bool)
    {
        self.imageView = imageView
        self.fullImageView = fullImageView
        self.shouldFadeOut = shouldFadeOut

        setupAnimation()
    }

    func start(isOn: Bool = true) {
        self.isOn = isOn
        removeLayerAnimations()
        animation?.perform()
    }

    func setOnCompleted(_ onCompleted: (() -> Void)?) {
        self.onCompleted = onCompleted
    }

    func setOnScaleDown(_ onScaleDown: (() -> Void)?) {
        self.onScaleDown = onScaleDown
    }
}

// MARK: - UI

extension FavorAnimator {
    func setupFullImage() {
        guard let imageView else { return }

        fullImageView?.sr
            .add(to: imageView)
            .makeConstraints { make in
                make.edges.equalToSuperview()
            }
            .other {
                $0.layer.opacity = 0
            }
    }

    func updateColors(
        normalColor: UIColor? = nil,
        selectedColor: UIColor? = nil)
    {
        if let normalColor {
            imageView?.image = .init(systemName: "heart")?.masked(normalColor)
        }

        if let selectedColor {
            fullImageView?.image = .init(systemName: "heart.fill")?.masked(selectedColor)
        }
    }

    func removeLayerAnimations() {
        imageView?.layer.removeAllAnimations()
        fullImageView?.layer.removeAllAnimations()
    }

    private func setupAnimation() {
        let scale = ScaleAnimation(layer: imageView?.layer)
            .onScaleDown { [weak self] in
                guard let self else { return }
                self.fullImageView?.layer.opacity = self.isOn ? 1 : 0
                self.onScaleDown?()
            }

        if shouldFadeOut {
            let fadeOut = FadeAnimation(layer: fullImageView?.layer)
                .onCompleted { [weak self] in
                    guard let self, $0 else { return }
                    self.fullImageView?.layer.opacity = self.isOn ? 0 : 1
                    self.onCompleted?()
                }

            scale.nextAnimation(fadeOut)
        }
        else {
            scale.onCompleted { [weak self] _ in
                self?.onCompleted?()
            }
        }

        animation = scale
    }
}

// MARK: - Preview

#if swift(>=5.9)
    fileprivate class FavorAnimator_Preview: BaseHighlightableView {
        @Stylish
        private var imageView = UIImageView()
        @Stylish
        private var fullImageView = UIImageView()

        private lazy var animator = FavorAnimator(imageView: imageView, fullImageView: fullImageView, shouldFadeOut: true)

        private var isFavor = false

        init() {
            super.init(frame: .zero)

            $imageView
                .add(to: self)
                .makeConstraints { make in
                    make.edges.equalToSuperview()
                }

            animator.setupFullImage()
            animator.updateColors(normalColor: .gray, selectedColor: .red)

            sr.makeConstraints { make in
                make.size.equalTo(50)
            }

            onTap = { [weak self] _ in
                self?.setIsFavor()
            }

            setupGesture()
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setIsFavor() {
            isFavor = !isFavor
            animator.start(isOn: isFavor)
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        FavorAnimator_Preview()
    }
#endif
