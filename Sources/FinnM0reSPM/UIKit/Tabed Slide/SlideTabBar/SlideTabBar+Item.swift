import Foundation
import UIKit

extension SlideTabBar {
  public class Item: UIView {
    public struct Model {
      var font = UIFont.systemFont(ofSize: 17)
      var selectedFont = UIFont.systemFont(ofSize: 17)
      var color: UIColor = .black
      var selectedColor: UIColor = .blue
    }

    func setSelected(_: Bool) { }
    func setTransformingColor(_: UIColor) { }
  }

  public class DefaultItem: Item {
    private(set) var titleLabel = UILabel()

    private let model: Model

    public init(model: Model) {
      self.model = model
      super.init(frame: .zero)
      self.commitInit()
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

    override public func setSelected(_ isSelected: Bool) {
      titleLabel.textColor = isSelected ? model.selectedColor : model.color
      titleLabel.font = isSelected ? model.selectedFont : model.font
    }

    override public func setTransformingColor(_ color: UIColor) {
      titleLabel.textColor = color
    }
  }
}
