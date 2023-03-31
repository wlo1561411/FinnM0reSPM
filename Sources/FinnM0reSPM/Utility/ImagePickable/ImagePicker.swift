import AVFoundation
import Photos
import RxCocoa
import RxSwift
import UIKit

// TODO: Need to check UIImagePickerController
public final class ImagePicker: NSObject {
  public typealias ImageResult = (type: UIImagePickerController.SourceType, status: ImagePicker.Status)
  typealias Source = (imgResult: ImageResult?, authorization: ImagePicker.Error.Authorization?)

  let resultSubject = PublishSubject<Source>()

  public var resultDriver: Driver<ImageResult> {
    resultSubject
      .map { result, authorization -> ImageResult in
        if let result {
          return result
        }
        else {
          guard let authorization else {
            throw ImagePicker.Error.typeError
          }
          throw ImagePicker.Error.fail(authorization)
        }
      }
      .asDriver(onErrorJustReturn: (type: .camera, status: .cancel))
  }

  func present(
    sourceType: UIImagePickerController.SourceType,
    allowsEditing: Bool = false,
    to viewController: UIViewController)
  {
    DispatchQueue.main.async {
      let controller = UIImagePickerController()
      controller.delegate = self
      controller.sourceType = sourceType
      controller.allowsEditing = allowsEditing
      viewController.present(controller, animated: true, completion: nil)
    }
  }
}

// MARK: - Model

extension ImagePicker {
  public enum Error: Swift.Error {
    public enum Authorization {
      case photo(PHAuthorizationStatus)
      case camera(AVAuthorizationStatus)
    }

    case fail(Authorization)
    case typeError
  }

  public enum Status: Equatable {
    case success(UIImage?)
    case cancel

    var image: UIImage? {
      switch self {
      case .success(let img):
        return img
      default:
        return nil
      }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.image == rhs.image
    }
  }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  public func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
  {
    if let image = info[.editedImage] as? UIImage {
      resultSubject.onNext((imgResult: (type: picker.sourceType, status: .success(image)), authorization: nil))
    }
    else if let image = info[.originalImage] as? UIImage {
      resultSubject.onNext((imgResult: (type: picker.sourceType, status: .success(image)), authorization: nil))
    }
    else {
      print("Other source")
    }
    
    picker.dismiss(animated: true, completion: nil)
  }

  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    resultSubject.onNext((imgResult: (type: picker.sourceType, status: .cancel), authorization: nil))
    picker.dismiss(animated: true, completion: nil)
  }
}
