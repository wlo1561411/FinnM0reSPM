import UIKit

// MARK: - General

extension String {
  public var attributed: NSMutableAttributedString {
    .init(string: self)
  }

  public var orEmpty: String? {
    isEmpty ? nil : self
  }

  public var halfWidth: String {
    let string = NSMutableString(string: self) as CFMutableString
    CFStringTransform(string, nil, kCFStringTransformFullwidthHalfwidth, false)
    return string as String
  }
  
  public func formated(_ arguments: [CVarArg?] = []) -> String {
    if arguments.count > 0 {
      return String(format: self, arguments: arguments.compactMap { $0 })
    }
    else {
      return self
    }
  }

  public func ranges(of occurrence: String) -> [Range<String.Index>] {
    var indices = [Int]()
    var position = startIndex

    while let range = range(of: occurrence, range: position..<endIndex) {
      let offset = occurrence.distance(from: occurrence.startIndex, to: occurrence.endIndex) - 1
      guard
        let after = index(
          range.lowerBound,
          offsetBy: offset,
          limitedBy: endIndex)
      else { break }

      indices.append(distance(from: startIndex, to: range.lowerBound))
      position = index(after: after)
    }

    let count = occurrence.count
    return indices.map { index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0 + count) }
  }

  public func width(with font: UIFont) -> CGFloat {
    ceil(
      NSString(string: self)
        .boundingRect(
          with: CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: font.lineHeight),
          options: .usesLineFragmentOrigin,
          attributes: [NSAttributedString.Key.font: font],
          context: nil).size.width)
  }

  public func height(with font: UIFont, width: CGFloat) -> CGFloat {
    ceil(
      NSString(string: self)
        .boundingRect(
          with: CGSize(
            width: width,
            height: CGFloat.greatestFiniteMagnitude),
          options: .usesLineFragmentOrigin,
          attributes: [NSAttributedString.Key.font: font],
          context: nil).size.height)
  }

  public func htmlStripped() -> String {
    replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
      .replacingOccurrences(of: "\n", with: "")
      .replacingOccurrences(of: " ", with: "")
  }

  public func spaceByFour(suffix: Int?) -> String {
    let fixed = replacingOccurrences(of: " ", with: "")
    var temp = ""
    for (key, value) in fixed.enumerated() {
      if let suffix {
        if key >= count - suffix {
          temp += "\(value)"
        }
        else {
          temp += "*"
        }
      }
      else {
        temp += "\(value)"
      }

      if (key + 1) % 4 == 0, key != 0 {
        temp += " "
      }
    }
    return temp
  }

  public func versionCompare(_ otherVersion: String?) -> ComparisonResult {
    compare(otherVersion ?? "", options: .numeric)
  }
}

// MARK: - Regular Expression

extension String {
  public enum Regex: String {
    case password
    case username
    case phone
    case realName
    case otp
    case id
    case referrerCode
    case email
    case receiverRemark
    case weChat
    case address
    case securityQuestionAnswer
    case serialNumber
    case securityCode
    case bankAccountNumber
    case bankName
    case bankAddress
    case cryptoWalletName
    case cryptoWalletAddressTRC
    case cryptoWalletAddressERC
    case pureToken

    var value: String {
      switch self {
      case .password:
        return "^(?=^.{6,14}$)(?=.*[0-9])(?=.*[a-zA-Z])(?=.*[^@$#])([a-zA-Z0-9^@$#]+)$"
      case .username:
        return "^[A-Za-z0-9]{6,20}$"
      case .phone:
        return "^[0-9]{11}$"
      case .realName:
        return "^(?! )[\\p{Han} ·•]{2,50}(?<! )$"
      case .otp:
        return "^[0-9]{6}$"
      case .id:
        return "(?:[16][1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4])\\d{4}(?:19|20)\\d{2}(?:(?:0[469]|11)(?:0[1-9]|[12][0-9]|30)|(?:0[13578]|1[02])(?:0[1-9]|[12][0-9]|3[01])|02(?:0[1-9]|[12][0-9]))\\d{3}[\\dXx]"
      case .referrerCode:
        return "^([A-Za-z0-9]{1,20})$"
      case .email:
        return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      case .receiverRemark:
        return "^[a-zA-Z0-9\\s\\p{Han}.?()/&:!#,-]+"
      case .weChat:
        return "^[a-zA-Z0-9.@_-]{4,20}$"
      case .address:
        return "[A-Za-z0-9\\s\\p{Han}.()/&#,-]+"
      case .securityQuestionAnswer:
        return "[A-Za-z0-9\\u4e00-\\u9fa5\\s\\p{Han}!#$(),./\\?_]+"
      case .serialNumber:
        return "^[0-9]{16}$"
      case .securityCode:
        return "^[0-9]{3}$"
      case .bankAccountNumber:
        return "^[0-9]{16,19}$"
      case .bankName:
        return "^[\\p{Han}a-zA-Z]{2,20}$"
      case .bankAddress:
        return "^[\\p{Han}a-zA-Z]{2,50}$"
      case .cryptoWalletName:
        return "^[a-zA-Z0-9/\\p{L}/u]{1,20}$"
      case .cryptoWalletAddressTRC:
        return "^[T]{1}[a-zA-Z0-9]{33}+$"
      case .cryptoWalletAddressERC:
        return "^[0x]{2}[a-zA-Z0-9]{40}+$"
      case .pureToken:
        return "(?<=\\s).*"
      }
    }
  }

  public static func ~= (lhs: String, rhs: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
    let range = NSRange(location: 0, length: lhs.utf16.count)
    return regex.firstMatch(in: lhs, options: [], range: range) != nil
  }

  public func valid(_ regex: Regex) -> Bool {
    self ~= regex.value
  }

  public func match(_ regex: Regex) -> [String] {
    let _string = self as NSString
    return (try? NSRegularExpression(pattern: regex.value))?
      .matches(
        in: self,
        range: NSRange(location: 0, length: _string.length))
      .map {
        _string.substring(with: $0.range)
      } ?? []
  }
}

// MARK: - Mask

extension String {
  public enum Mask {
    case left(Int)
    case email
    /// It wil escape "$"
    case allMasked
  }

  public func masked(_ type: Mask) -> String {
    switch type {
    case .left(let count):
      return enumerated()
        .map { key, value -> String in
          if count > 0, (self.count - key - 1) < count {
            return "\(value)"
          }
          else {
            return "*"
          }
        }
        .joined()

    case .email:
      var count = 0
      var detectAt = false

      return enumerated()
        .map { _, value -> String in
          if !detectAt {
            detectAt = "\(value)" == "@"
          }

          if detectAt {
            return "\(value)"
          }
          else {
            if count < 3 {
              count += 1
              return "\(value)"
            }
            else {
              return "*"
            }
          }
        }
        .joined()

    case .allMasked:
      let currency = "$"

      return self.map { characters -> String in
        if "\(characters)" == " " || currency == "\(characters)" {
          return "\(characters)"
        }
        return "*"
      }
      .joined()
    }
  }
}

// MARK: - Date

extension String {
  public enum DateFormat: String {
    public enum ISO8601 {
      /// Format: 2021-05-31T11:00:00.000Z
      case standard

      var options: ISO8601DateFormatter.Options {
        switch self {
        case .standard:
          return [.withFractionalSeconds, .withInternetDateTime]
        }
      }
    }

    case yyyyMMddWithSlash = "yyyy/MM/dd"
    case yyyyMMddWithSymbol = "yyyy-MM-dd"
    case MMddyyyyWithSlash = "MM/dd/yyyy"
    case yyyyMMdd
    case fullTimeWithSymbol = "yyyy-MM-dd HH:mm:ss"
    case fullTimeWithSlash = "yyyy/MM/dd HH:mm:ss"
    case fullTimeMillisecond = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    case yyyyMMWithSlash = "yyyy/MM"
    case MMyyyyWithSlash = "MM/yyyy"
    case iso8601WithTimeZone = "yyyy-MM-dd'T'HH:mm:ss"
    case MMyyWithSlash = "MM/yy"
    case MDHM = "M/d HH:mm"
    case cnyMd = "M 月 d 日"
    case imToken = "yyyy-MM-dd HH:mm:ss.ssss"
  }

  /// Need to collect the other situation
  public func dateFromISO8601(_ type: DateFormat.ISO8601) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = .init(identifier: "Asia/Hong_Kong")
    formatter.formatOptions = type.options
    return formatter.date(from: self)
  }

  public func dateFromFormat(_ format: DateFormat) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = format.rawValue
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter.date(from: self)
  }
}

// MARK: - NSMutableAttributedString

extension NSMutableAttributedString {
  public func textColor(_ color: UIColor) -> NSMutableAttributedString {
    addAttribute(
      .foregroundColor,
      value: color,
      range: .init(location: 0, length: self.length))
    return self
  }

  public func font(_ font: UIFont) -> NSMutableAttributedString {
    addAttribute(
      .font,
      value: font,
      range: .init(location: 0, length: self.length))
    return self
  }

  public func characterSpacing(_ spacing: CGFloat) -> NSMutableAttributedString {
    addAttribute(
      .kern,
      value: spacing,
      range: .init(location: 0, length: self.length - 1))
    return self
  }

  public func textAlignment(_ alignment: NSTextAlignment) -> NSMutableAttributedString {
    if let pre = attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle {
      pre.alignment = alignment
      return self
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment

    addAttribute(
      .paragraphStyle,
      value: paragraphStyle,
      range: .init(location: 0, length: self.length))
    return self
  }

  public func lineSpacing(_ spacing: CGFloat) -> NSMutableAttributedString {
    if let pre = attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle {
      pre.lineSpacing = spacing
      return self
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = spacing

    addAttribute(
      NSAttributedString.Key.paragraphStyle,
      value: paragraphStyle,
      range: NSMakeRange(0, self.length))
    return self
  }

  public func highlight(
    font: UIFont,
    color: UIColor,
    rangeSubString: String)
    -> NSMutableAttributedString
  {
    string.ranges(of: rangeSubString)
      .forEach {
        addAttributes(
          [.font: font, .foregroundColor: color],
          range: NSRange($0, in: self.string))
      }
    return self
  }

  public func highlights(
    font: UIFont,
    color: UIColor,
    rangeSubStrings: [String?])
    -> NSMutableAttributedString
  {
    rangeSubStrings
      .compactMap { $0 }
      .forEach { string in
        let _ = highlight(font: font, color: color, rangeSubString: string)
      }
    return self
  }
}
