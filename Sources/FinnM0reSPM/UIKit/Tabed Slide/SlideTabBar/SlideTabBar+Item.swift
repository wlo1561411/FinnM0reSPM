import Foundation
import UIKit

public protocol SlideTabBarItem: UIView {
    typealias Settings = [SlideTabBar.ItemSetting.Status: SlideTabBar.ItemSetting]

    func setSelected(_ isSelected: Bool, settings: Settings)
    func setEnable(_ isEnable: Bool, settings: Settings)
    func setTransformingColor(_ color: UIColor)
}

extension SlideTabBarItem {
    public static func empty() -> Self where Self == SlideTabBar.DefaultItem {
        .init()
    }
}

extension SlideTabBar {
    public struct ItemSetting {
        public enum Status {
            case normal
            case selected
            case disable
        }

        var font: UIFont?
        var textColor: UIColor?
        var borderColor: UIColor?
        var borderWidth: CGFloat?
        var backgroundColor: UIColor?
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
            applySettings(for: isSelected ? .selected : .normal, settings: settings)
        }

        public func setEnable(_ isEnable: Bool, settings: Settings) {
            applySettings(for: isEnable ? .normal : .disable, settings: settings)
        }

        public func setTransformingColor(_ color: UIColor) {
            titleLabel.textColor = color
        }

        private func applySettings(for status: ItemSetting.Status, settings: Settings) {
            let normalSetting = settings[.normal]
            let currentSetting = settings[status]

            let textColor = currentSetting?.textColor ?? normalSetting?.textColor ?? .clear
            let font = currentSetting?.font ?? normalSetting?.font ?? .systemFont(ofSize: 14)
            let backgroundColor = currentSetting?.backgroundColor ?? normalSetting?.backgroundColor ?? .clear
            let borderColor = currentSetting?.borderColor ?? normalSetting?.borderColor ?? .clear
            let borderWidth = currentSetting?.borderWidth ?? normalSetting?.borderWidth ?? 0

            titleLabel.textColor = textColor
            titleLabel.font = font

            self.backgroundColor = backgroundColor
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = borderWidth
        }
    }
}
