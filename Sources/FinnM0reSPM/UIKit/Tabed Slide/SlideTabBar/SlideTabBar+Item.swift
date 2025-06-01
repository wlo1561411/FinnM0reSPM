import Foundation
import UIKit

public protocol SlideTabBarItem: UIView {
    typealias Settings = [SlideTabBar.ItemSetting.Status: SlideTabBar.ItemSetting]

    func setSelected(_ isSelected: Bool, settings: Settings)
    func setEnable(_ isEnable: Bool, settings: Settings)
    func setTransformingColor(_ color: UIColor)
}

// MARK: - Data Handle

extension SlideTabBarItem {
    func getSetting(for status: SlideTabBar.ItemSetting.Status, settings: SlideTabBarItem.Settings) -> SlideTabBar.ItemSetting {
        let normalSetting = settings[.normal]
        let currentSetting = settings[status]

        return .init(
            font: currentSetting?.font ?? normalSetting?.font ?? .systemFont(ofSize: 14),
            textColor: currentSetting?.textColor ?? normalSetting?.textColor ?? .clear,
            borderColor: currentSetting?.borderColor ?? normalSetting?.borderColor ?? .clear,
            borderWidth: currentSetting?.borderWidth ?? normalSetting?.borderWidth ?? 0,
            backgroundColor: currentSetting?.backgroundColor ?? normalSetting?.backgroundColor ?? .clear)
    }
}

// MARK: - ItemSetting

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
}

// MARK: - DefaultItem

extension SlideTabBar {
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
            let setting = getSetting(for: status, settings: settings)

            titleLabel.textColor = setting.textColor
            titleLabel.font = setting.font

            backgroundColor = setting.backgroundColor

            layer.borderColor = (setting.borderColor ?? .clear).cgColor
            layer.borderWidth = setting.borderWidth ?? 0
        }
    }
}
