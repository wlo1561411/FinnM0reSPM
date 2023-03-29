import RxSwift
import UIKit

@available(iOS 14.0, *)
class Tester: UIViewController {
  let bag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .lightGray

    UIButton().sr
      .titleColor(.blue)
      .backgroundColor(.systemBlue)
      .observe(from: Observable.just("testOne"), to: { $0.rx.title() }, dispose: bag)
      .add(to: view)
      .makeConstraints { make in
        make.center.equalToSuperview()
      }
      .tap(
        on: { [weak self] _ in
          self?.view.backgroundColor = .white
        }, dispose: bag)
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
