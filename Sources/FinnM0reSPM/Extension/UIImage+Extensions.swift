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

    public func masked(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(
            origin: .zero,
            size: CGSize(width: size.width, height: size.height))
        context?.clip(to: rect, mask: cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let resultImage = newImage {
            return resultImage
        }
        else {
            return nil
        }
    }

    public func compress() -> (size: Double, imgData: String)? {
        let fixedImage: UIImage = fixedOrientation() ?? self
        guard let data = fixedImage.jpegData(compressionQuality: 0.6) else { return nil }

        let imageSize = Double(data.count) / 1000.0
        let imgDataBase64: String = data.base64EncodedString(options: .lineLength64Characters)

        return (size: imageSize, imgData: imgDataBase64)
    }

    public enum ResizeAlignment {
        case bottom
        case none
    }

    public func resize(
        to targetSize: CGSize,
        alignment: ResizeAlignment = .none)
        -> UIImage?
    {
        let aspectRatio = size.width / size.height
        let newSize = CGSize(width: targetSize.width, height: targetSize.width / aspectRatio)

        let originY: CGFloat
        switch alignment {
        case .bottom:
            originY = targetSize.height - newSize.height
        case .none:
            originY = 0
        }

        let rect = CGRect(origin: CGPoint(x: 0, y: originY), size: newSize)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
