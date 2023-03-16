public struct Styler<Base> {
  public let base: Base

  public init(_ base: Base) {
    self.base = base
  }
}

public protocol StylerCompatible {
  associatedtype Base

  var sr: Styler<Base> { get set }
}

extension StylerCompatible {
  public var sr: Styler<Self> {
    get { Styler(self) }
    set { }
  }
}
