import Combine
import RxSwift
import UIKit

@available(iOS 14.0, *)
public class Tester: UIViewController, Previewable {
  let bag = DisposeBag()
  var cancellables = Set<AnyCancellable>()

  @Stylish var tab1: SlideTabBar = .init()
  @Stylish var label: UILabel = .init()

  override public func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .lightGray

    $tab1
      .add(to: view)
      .makeConstraints { make in
        make.top.equalToSuperview().offset(100)
        make.left.right.equalToSuperview().inset(30)
        make.height.equalTo(50)
      }
      .distribution(.contentLeading)
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

    $label
      .textAlignment(.center)
      .add(to: view)
      .makeConstraints({ make in
        make.left.right.equalToSuperview()
        make.bottom.equalToSuperview().inset(100)
      })
      .assign(
        from: Future<String, Never> { promise in
          DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            promise(.success("Hello, Combine!"))
          }
        }
        .map(Optional.init)
        .eraseToAnyPublisher(),
        to: \.text,
        cancellables: &cancellables)
  }

  deinit {
    print("Tester dead")
  }
}

#if canImport(SwiftUI) && DEBUG
  import SwiftUI

  @available(iOS 14.0, *)
  struct TesterPreview: PreviewProvider {
    static let t = Tester()
    static var previews: some View {
      t.previewable()
    }
  }
#endif
