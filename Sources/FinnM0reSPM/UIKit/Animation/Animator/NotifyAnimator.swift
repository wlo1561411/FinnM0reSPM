import UIKit

class NotifyAnimator {
    enum Style {
        case zeroToOne
        case normal
        case oneToZero
    }

    private weak var view: UIView?
    private weak var label: UILabel?

    private var animation: Animation?

    private let textFactory: (Int) -> String

    var currentValue: Int {
        Int(label?.text ?? "") ?? 0
    }

    init(
        view: UIView,
        label: UILabel,
        textFactory: @escaping (Int) -> String)
    {
        self.view = view
        self.label = label
        self.textFactory = textFactory
    }

    func start() {
        animation?.perform()
    }
}

// MARK: - UI

extension NotifyAnimator {
    func setupNotifyView() {
        view?.isHidden = false
        view?.alpha = 0
    }

    func updateIfNeeded(value: Int) {
        if value == 0, currentValue == 1 {
            animation = nil
            setupNotifyAnimation(style: .oneToZero)
        }
        else if value == 1, currentValue == 0 {
            updateValue(value: value)
            animation = nil
            setupNotifyAnimation(style: .zeroToOne)
        }
        else {
            updateValue(value: value)
        }
    }

    private func setupNotifyAnimation(style: Style) {
        switch style {
        case .oneToZero,
             .zeroToOne:
            let upValue: CGFloat = style == .zeroToOne ? 0 : 1
            let downValue: CGFloat = style == .zeroToOne ? 1 : 0

            view?.layer.transform = CATransform3DMakeScale(upValue, upValue, upValue)

            let fullOverScaleUp = ScaleAnimation(fromValue: upValue, toValue: 1.2, layer: view?.layer)
                .style(.normal)
                .onCompleted { [weak self] _ in
                    self?.animation = nil
                    self?.setupNotifyAnimation(style: .normal)
                }

            let scaleDown = ScaleAnimation(fromValue: 1.2, toValue: downValue, layer: view?.layer)
                .style(.normal)
                .onCompleted { [weak self] finish in
                    guard finish, style == .oneToZero else { return }
                    self?.updateValue(value: 0)
                }

            /// fullOverScaleUp only when notifyView isHidden and perform once
            animation = fullOverScaleUp.nextAnimation(scaleDown)

        case .normal:
            view?.layer.transform = CATransform3DMakeScale(1, 1, 1)
            animation = ScaleAnimation(toValue: 0.6, layer: view?.layer)
        }
    }

    private func updateValue(value: Int? = nil) {
        let _value = value ?? currentValue
        let text = textFactory(_value)

        view?.alpha = text.isEmpty ? 0 : 1
        label?.text = text
    }
}

// MARK: - Preview

#if swift(>=5.9)
    import Combine

    fileprivate class NotifyAnimator_Preview: UIView {
        @Stylish
        private var plusButton = UIButton()
        @Stylish
        private var minusButton = UIButton()
        @Stylish
        private var countLabel = UILabel()

        private lazy var notifyAnimator = NotifyAnimator(
            view: countLabel,
            label: countLabel,
            textFactory: {
                if $0 <= 0 {
                    return ""
                }
                else {
                    return $0 > 99 ? "99+" : "\($0)"
                }
            })

        private var cancellable = Set<AnyCancellable>()

        private var value = 0

        init() {
            super.init(frame: .zero)

            $plusButton
                .backgroundColor(.darkGray)
                .title("+")
                .titleColor(.white)
                .onTap(store: &cancellable) { [weak self] _ in
                    self?.value += 1
                    self?.update()
                }

            $minusButton
                .backgroundColor(.darkGray)
                .title("-")
                .titleColor(.white)
                .onTap(store: &cancellable) { [weak self] _ in
                    self?.value -= 1
                    self?.update()
                }

            let buttons = UIStackView().sr
                .axis(.horizontal)
                .addArranged([plusButton, minusButton])
                .config(spacing: 10, alignment: .fill, distribution: .fillEqually)
                .add(to: self)
                .makeConstraints { make in
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(30)
                }
                .unwrap()

            $countLabel
                .backgroundColor(.systemOrange)
                .textColor(.white)
                .textAlignment(.center)
                .round(15)
                .add(to: self)
                .makeConstraints { make in
                    make.top.equalTo(buttons.snp.bottom).offset(10)
                    make.size.equalTo(30)
                    make.bottom.centerX.equalToSuperview()
                }

            notifyAnimator.setupNotifyView()
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func update() {
            notifyAnimator.updateIfNeeded(value: value)
            notifyAnimator.start()
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        NotifyAnimator_Preview()
    }
#endif
