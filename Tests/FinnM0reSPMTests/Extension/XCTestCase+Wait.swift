import XCTest

extension XCTestCase {
  func delay(for duration: TimeInterval, _ completion: (() -> Void)?) {
    let when = DispatchTime.now() + duration
    DispatchQueue.main.asyncAfter(deadline: when) {
      completion?()
    }
  }
  
  func wait(for duration: TimeInterval, _ action: (() -> Void)?) {
    let waitExpectation = expectation(description: "Waiting")
    delay(for: duration) {
      waitExpectation.fulfill()
    }
    waitForExpectations(timeout: duration + 0.5)
  }
}
