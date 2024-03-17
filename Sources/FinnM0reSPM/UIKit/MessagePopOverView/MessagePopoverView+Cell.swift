import UIKit

extension MessagePopoverView {
    class SeparatorCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .clear
            contentView.backgroundColor = .clear

            let line = UIView()
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
        private let titleLabel = UILabel()

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

        func config(_ style: MessagePopoverView.Style) {
            titleLabel.text = style.localizedText
        }
    }
}
