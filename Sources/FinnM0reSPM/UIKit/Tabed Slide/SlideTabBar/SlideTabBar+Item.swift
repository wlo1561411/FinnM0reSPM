import Foundation
import UIKit

public protocol SlideTabBarItem: UIView {
    typealias Settings = [SlideTabBar.ItemSetting.Status: SlideTabBar.ItemSetting]

    func setSelected(_ isSelected: Bool, settings: Settings)
    func setEnable(_ isEnable: Bool, settings: Settings)
    func setTransformingColor(_ color: UIColor)
}

extension SlideTabBarItem where Self == SlideTabBar.DefaultItem {
    public static var empty: SlideTabBar.DefaultItem { .init() }
}

extension SlideTabBar {
    public struct ItemSetting {
        public enum Status {
            case normal
            case selected
            case disable
        }

        var font: UIFont?
        var color: UIColor?
    }

    public class DefaultItem: UIView, SlideTabBarItem {
        private(set) var titleLabel = UILabel()

        init() {
            super.init(frame: .zero)
            commitInit()
        }

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

        public func setSelected(_ isSelected: Bool, settings: Settings) {
            if let color = isSelected ? settings[.selected]?.color : settings[.normal]?.color {
                titleLabel.textColor = color
            }

            if let font = isSelected ? settings[.selected]?.font : settings[.normal]?.font {
                titleLabel.font = font
            }
        }

        public func setEnable(_ isEnable: Bool, settings: Settings) {
            if let color = isEnable ? settings[.normal]?.color : settings[.disable]?.color {
                titleLabel.textColor = color
            }

            if let font = settings[.normal]?.font {
                titleLabel.font = font
            }
        }

        public func setTransformingColor(_ color: UIColor) {
            titleLabel.textColor = color
        }
    }
}
