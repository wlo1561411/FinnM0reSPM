import UIKit

extension SlideView.TabBar {
  public class Item: UIView {
    public struct Model {
      var font = UIFont.systemFont(ofSize: 17)
      var selectedFont = UIFont.systemFont(ofSize: 17)
      var color: UIColor = .black
      var selectedColor: UIColor = .blue
    }

    private(set) var titleLabel = UILabel()

    private(set) var isSelected = false

    var tapAction: (() -> Void)?

    var model: Model = .init()

    public init() {
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
      
      addSubview(titleLabel)
      titleLabel.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
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

    func prepareReinit() {
      tapAction = nil
    }
  }
}
