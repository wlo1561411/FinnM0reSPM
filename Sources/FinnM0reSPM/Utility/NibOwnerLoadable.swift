import UIKit

protocol NibOwnerLoadable: AnyObject {
  static var nib: UINib { get }
}

// MARK: - Default Implementation

extension NibOwnerLoadable {
  static var nib: UINib {
    UINib(nibName: String(describing: self), bundle: Bundle(for: self))
  }
}

// MARK: - Supporting Methods

extension NibOwnerLoadable where Self: UIView {
  static func loadFromNib() -> Self {
    guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
      fatalError("Fail to load \(self) nib")
    }
    return view
  }

  func loadNibContent() {
    guard
      let views = Self.nib.instantiate(withOwner: self, options: nil) as? [UIView],
      let contentView = views.first
    else {
      fatalError("Fail to load \(self) nib content")
    }
    self.addSubview(contentView)
    contentView.backgroundColor = .clear
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
}
