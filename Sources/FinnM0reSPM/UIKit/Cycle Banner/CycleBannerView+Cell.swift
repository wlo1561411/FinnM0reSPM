import UIKit

extension CycleBannerView {
  class Cell: UICollectionViewCell {
    private(set) var embeddedView: UIView?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      backgroundColor = .clear
      contentView.backgroundColor = .clear
    }

    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func embed(_ view: UIView?, space: CGFloat, size: CGSize) {
      embeddedView = view

      guard let embeddedView else { return }
      
      contentView.addSubview(embeddedView)
      embeddedView.snp.makeConstraints { make in
        make.top.bottom.equalToSuperview().priority(.high)
        make.left.right.equalToSuperview().inset(space).priority(.high)
        
        let fixedSize = CGSize(width: size.width - (space * 2), height: size.height)
        make.size.equalTo(fixedSize).priority(.high)
      }
    }

    override func prepareForReuse() {
      super.prepareForReuse()
      embeddedView?.removeFromSuperview()
      embeddedView = nil
    }
  }
}
