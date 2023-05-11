import RxSwift
import UIKit

@available(iOS 14.0, *)
class Tester: UIViewController {
  let bag = DisposeBag()

  @Stylish var tab1: SlideTabBar = .init()
  @Stylish var tab2: SlideTabBar = .init()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .lightGray

    $tab1
      .add(to: view)
      .makeConstraints { make in
        make.top.equalToSuperview().offset(50)
        make.left.right.equalToSuperview().inset(30)
        make.height.equalTo(50)
      }
      .distribution(.contentCenter)
      .other {
        Observable.just((0...3).map { "Test\($0)" })
          .bind(to: $0.rx.titles)
          .disposed(by: self.bag)
      }

    $tab2
      .add(to: view)
      .makeConstraints { make in
        make.top.equalToSuperview().offset(150)
        make.left.right.equalToSuperview().inset(30)
        make.height.equalTo(50)
      }
      .distribution(.contentLeading)
      .other {
        Observable.just((0...10).map { "Test\($0)" })
          .bind(to: $0.rx.titles)
          .disposed(by: self.bag)
      }
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
