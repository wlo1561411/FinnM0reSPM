import UIKit

extension CycleBannerView {
    // TODO: Too many count will wrong, maybe can use UIPageControl
    public class PageControl: UIView {
        private let stackView = UIStackView()

        private var selectedImageName = ""
        private var unselectedImageName = ""

        private var _selectedIndex = 0

        public var selectedIndex: Int {
            get { _selectedIndex }
            set {
                for (key, view) in stackView.arrangedSubviews.enumerated() {
                    guard let imageView = view as? UIImageView else { break }
                    if key == _selectedIndex { imageView.image = .init(named: unselectedImageName) }
                    if key == newValue { imageView.image = .init(named: selectedImageName) }
                }

                _selectedIndex = newValue
            }
        }

        convenience init(
            count: Int,
            selectedImageName: String,
            unselectedImageName: String)
        {
            self.init(frame: .zero)
            configItems(count: count, selectedImageName: selectedImageName, unselectedImageName: unselectedImageName)
        }

        override public init(frame: CGRect) {
            super.init(frame: frame)
            commitInit()
        }

        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func commitInit() {
            stackView.axis = .horizontal
            stackView.spacing = 4
            stackView.distribution = .equalSpacing
            stackView.alignment = .center

            addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.bottom.equalToSuperview()
            }
        }

        public func configItems(
            count: Int,
            selectedImageName: String,
            unselectedImageName: String)
        {
            _selectedIndex = 0

            isHidden = count <= 1
            self.selectedImageName = selectedImageName
            self.unselectedImageName = unselectedImageName

            stackView.removeAllFully()

            for item in 0..<count {
                stackView.addArrangedSubview(buildImageView(index: item))
            }
        }

        private func buildImageView(index: Int) -> UIImageView {
            let view = UIImageView()
            view.image = .init(named: index == _selectedIndex ? selectedImageName : unselectedImageName)
            view.tag = index
            return view
        }
    }
}
