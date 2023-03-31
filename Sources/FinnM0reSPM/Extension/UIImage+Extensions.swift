import UIKit

extension UIImage {
  public func fixedOrientation() -> UIImage? {
    switch imageOrientation {
    case .up:
      return self
    default:
      UIGraphicsBeginImageContextWithOptions(size, false, scale)
      draw(in: CGRect(origin: .zero, size: size))
      let result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return result
    }
  }

  public func compress() -> (size: Double, imgData: String)? {
    let fixedImage: UIImage = fixedOrientation() ?? self
    guard let data = fixedImage.jpegData(compressionQuality: 0.6) else { return nil }

    let imageSize = Double(data.count) / 1000.0
    let imgDataBase64: String = data.base64EncodedString(options: .lineLength64Characters)

    return (size: imageSize, imgData: imgDataBase64)
  }
}
