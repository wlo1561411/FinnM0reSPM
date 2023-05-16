import Combine
import RxSwift
import UIKit

@available(iOS 14.0, *)
public class Tester: UIViewController, Previewable {
  let bag = DisposeBag()
  var cancellables = Set<AnyCancellable>()

  @Stylish var tab1: SlideTabBar = .init()
  @Stylish var tab2: SlideTabBar = .init()

  override public func viewDidLoad() {
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

    UIButton().sr
      .title("Press0")
      .titleColor(.magenta)
      .backgroundColor(.darkGray)
      .add(to: view)
      .makeConstraints { make in
        make.center.equalToSuperview()
        make.size.equalTo(100)
      }
      .unwrap()
      .publisher(for: .touchUpInside)
      .sink(receiveValue: {
          $0.tag += 1
          $0.sr.title("Press\($0.tag)")
      })
      .store(in: &cancellables)
  }
}

#if canImport(SwiftUI) && DEBUG
  import SwiftUI

  @available(iOS 14.0, *)
  struct TesterPreview: PreviewProvider {
    static var previews: some View {
      Tester().previewable()
    }
  }
#endif
