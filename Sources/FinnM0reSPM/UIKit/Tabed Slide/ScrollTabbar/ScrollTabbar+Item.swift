import UIKit

extension ScrollTabbarView {
  class Item: UIView {
    struct Model {
      var font = UIFont.systemFont(ofSize: 17)
      var selectedFont = UIFont.systemFont(ofSize: 17)
      var color: UIColor = .black
      var selectedColor: UIColor = .blue
    }

    private(set) var titleLabel = UILabel()

    private(set) var isSelected = false

    var tapAction: (() -> Void)?

    var contentWidth: CGFloat {
      SlideCalculator.textWidth(
        with: titleLabel.font,
        by: titleLabel.text ?? "")
    }

    var contentView: UIView {
      titleLabel
    }

    var model: Model = .init()

    init() {
      super.init(frame: .zero)
      self.commitInit()
    }

    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    private func commitInit() {
      let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
      addGestureRecognizer(tap)

      titleLabel.textAlignment = .center
      titleLabel.translatesAutoresizingMaskIntoConstraints = false

      addSubview(titleLabel)
      NSLayoutConstraint.activate(
        [
          titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
          titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    func setSelected(_ isSelected: Bool) {
      self.isSelected = isSelected

      titleLabel.textColor = isSelected ? model.selectedColor : model.color
      titleLabel.font = isSelected ? model.selectedFont : model.font
    }

    @objc
    private func tapped() {
      tapAction?()
    }

    func prepareDeinit() {
      tapAction = nil
    }
  }
}
