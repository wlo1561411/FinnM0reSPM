import SwiftUI

@available(iOS 14.0, *)
extension Spacer {
  
  public struct Limited: View {
    let pixel: CGFloat

    public init(_ pixel: CGFloat) {
      self.pixel = pixel
    }

    public var body: some View {
      Spacer(minLength: pixel)
        .fixedSize()
    }
  }
}

@available(iOS 14.0, *)
struct LimitSpacer_Previews: PreviewProvider {
  static var previews: some View {
    Spacer.Limited(5)
  }
}
