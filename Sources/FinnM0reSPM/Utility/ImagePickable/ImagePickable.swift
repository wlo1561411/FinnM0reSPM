import AVFoundation
import Photos
import RxCocoa
import RxSwift
import UIKit

public protocol ImagePickable {
  var imagePicker: ImagePicker { get }
}

extension ImagePickable where Self: UIViewController {
  public func cameraAccessRequest() {
    let status = AVCaptureDevice.authorizationStatus(for: .video)

    if status == .authorized {
      imagePicker.present(sourceType: .camera, to: self)
    }
    else {
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        guard let self else { return }

        if granted {
          self.imagePicker.present(sourceType: .camera, to: self)
        }
        else {
          self.imagePicker.resultSubject.onNext((imgResult: nil, authorization: .camera(status)))
        }
      }
    }
  }

  public func photoGalleryAccessRequest() {
    PHPhotoLibrary.requestAuthorization { [weak self] status in
      guard let self else { return }

      if status == .authorized {
        self.imagePicker.present(sourceType: .photoLibrary, to: self)
      }
      else {
        self.imagePicker.resultSubject.onNext((imgResult: nil, authorization: .photo(status)))
      }
    }
  }
}
