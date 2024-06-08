import Foundation

extension APILayer.RequestPriority {
    /// 一般級別，其值為 0.5
    public static let `default` = Self(URLSessionTask.defaultPriority)
    /// 低級別，其值為 0
    public static let low = Self(URLSessionTask.lowPriority)
    /// 高級別，其值為 1
    public static let high = Self(URLSessionTask.highPriority)
}

extension APILayer {
    /// 連線優先級
    public struct RequestPriority: RawRepresentable, Equatable {
        /// 優先等級，有效範圍 0 至 1。
        public var rawValue: Float

        /// 自定級別，有效範圍 0 至 1
        public init(rawValue: Float) {
            self.rawValue = rawValue
        }

        /// 自定級別，有效範圍 0 至 1
        public init(_ rawValue: Float) {
            self.rawValue = rawValue
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
    }
}
