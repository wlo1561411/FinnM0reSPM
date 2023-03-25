import UIKit
import RxSwift

@available(iOS 14.0, *)
class Tester: UIViewController {
  let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .lightGray
    
    let label = UILabel()
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview().inset(30)
    }

    let tabBar = SlideView.TabBar()

    view.addSubview(tabBar)
    tabBar.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(30)
      make.centerY.equalToSuperview()
      make.height.equalTo(40)
    }
    
    tabBar.itemSpace = 20
    tabBar.backgroundColor = .white
    
    Observable.just([
      "1234",
      "1234",
      "12399994",
      "1234",
      "1234",
      "1234",
      "1234",
//        "1234",
//        "1234",
//        "1234",
//        "1234",
    ])
    .bind(to: tabBar.rx.titles)
    .disposed(by: bag)
    
    tabBar.rx.didSelected
      .map { "\($1)" }
      .bind(to: label.rx.text)
      .disposed(by: bag)
  }
}

#if canImport(SwiftUI) && DEBUG
  import SwiftUI

  @available(iOS 14.0, *)
  struct Tester_Representable: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> some UIViewController {
      Tester()
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) { }
  }

  @available(iOS 14.0, *)
  struct TesterPreview: PreviewProvider {
    static var previews: some View {
      Tester_Representable()
    }
  }
#endif
