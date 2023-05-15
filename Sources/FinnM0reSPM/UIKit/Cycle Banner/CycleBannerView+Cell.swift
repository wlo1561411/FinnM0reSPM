import UIKit

extension CycleBannerView {
    public class Cell: UICollectionViewCell {
        private(set) var embeddedView: UIView?

        override public init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func embed(_ view: UIView?, space: CGFloat, size: CGSize) {
            embeddedView = view

            guard let embeddedView else { return }

            contentView.addSubview(embeddedView)
            embeddedView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().priority(.high)
                make.left.right.equalToSuperview().inset(space).priority(.high)

                let fixedSize = CGSize(width: size.width - (space * 2), height: size.height)
                make.size.equalTo(fixedSize).priority(.high)
            }
        }

        override public func prepareForReuse() {
            super.prepareForReuse()
            embeddedView?.removeFromSuperview()
            embeddedView = nil
        }
    }
}
