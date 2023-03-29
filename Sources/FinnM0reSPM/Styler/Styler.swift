@dynamicMemberLookup
public struct Styler<Base> {
  public let base: Base

  public init(_ base: Base) {
    self.base = base
  }
}

extension Styler {
  public func unwrap() -> Base { self.base }

  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Base, Value>) -> ((Value) -> Styler<Base>) {
    var _base = self.base

    return { value in
      _base[keyPath: keyPath] = value
      return .init(_base)
    }
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
