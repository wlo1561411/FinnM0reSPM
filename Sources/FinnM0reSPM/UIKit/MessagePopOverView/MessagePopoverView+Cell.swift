import UIKit

extension MessagePopoverView {
    class SeparatorCell: UICollectionViewCell {
        private(set) var line = UIView()

        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .clear
            contentView.backgroundColor = .clear

            line.backgroundColor = .darkGray

            contentView.addSubview(line)
            line.snp.makeConstraints { make in
                make.width.equalTo(2)
                make.height.equalTo(14)
                make.edges.centerY.equalToSuperview()
            }
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class ItemCell: UICollectionViewCell {
        private(set) var titleLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .clear
            contentView.backgroundColor = .clear

            titleLabel.textColor = .white
            titleLabel.textAlignment = .center
            titleLabel.font = .systemFont(ofSize: 12)

            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.height.equalTo(38)
                make.top.bottom.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(8)
            }
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class EmptyCell: UICollectionViewCell {
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
            -> UICollectionViewLayoutAttributes
        {
            let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            attributes.frame.size.width = 0
            return attributes
        }
    }
}
