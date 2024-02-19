import Foundation
import UIKit

extension SlideTabBar {
    public typealias Settings = [SlideTabBar.ItemSetting.Status: SlideTabBar.ItemSetting]

    public struct ItemSetting {
        public enum Status {
            case normal
            case selected
            case disable
        }

        var font: UIFont?
        var color: UIColor?
    }

    public class Item: UIView {
        public func setSelected(_: Bool, settings _: Settings) { }
        public func setEnable(_: Bool, settings _: Settings) { }
        public func setTransformingColor(_: UIColor) { }
    }

    public class DefaultItem: SlideTabBar.Item {
        private(set) var titleLabel = UILabel()

        init() {
            super.init(frame: .zero)
            commitInit()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func commitInit() {
            titleLabel.textAlignment = .center

            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        override public func setSelected(_ isSelected: Bool, settings: Settings) {
            if let color = isSelected ? settings[.selected]?.color : settings[.normal]?.color {
                titleLabel.textColor = color
            }

            if let font = isSelected ? settings[.selected]?.font : settings[.normal]?.font {
                titleLabel.font = font
            }
        }

        override public func setEnable(_ isEnable: Bool, settings: Settings) {
            if let color = isEnable ? settings[.normal]?.color : settings[.disable]?.color {
                titleLabel.textColor = color
            }

            if let font = settings[.normal]?.font {
                titleLabel.font = font
            }
        }

        override public func setTransformingColor(_ color: UIColor) {
            titleLabel.textColor = color
        }
    }
}
