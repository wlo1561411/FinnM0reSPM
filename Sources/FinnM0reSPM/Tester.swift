import RxSwift
import UIKit

@available(iOS 14.0, *)
class Tester: UIViewController {
  let bag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .lightGray
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
