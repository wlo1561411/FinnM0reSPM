import SwiftUI

@available(iOS 14.0, *)
public protocol LazyImageDownloader {
  func image(from url: String) async throws -> UIImage
}

@available(iOS 14.0, *)
extension LazyImage {
  class DefaultDownloader: LazyImageDownloader {
    
    func download(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
      guard let url = URL(string: url)
      else {
        completion(.failure(URLError(.badURL)))
        return
      }

      URLSession.shared
        .downloadTask(with: .init(url: url, timeoutInterval: 180)) { path, _, error in
          if let error {
            completion(.failure(error))
          }
          else if
            let path,
            let data = try? Data(contentsOf: path),
            let image = UIImage(data: data)
          {
            completion(.success(image))
          }
          else {
            completion(.failure(URLError(.cannotDecodeRawData)))
          }
        }
        .resume()
    }
    
    func image(from url: String) async throws -> UIImage {
      try await
        withCheckedThrowingContinuation { continuation in
          download(from: url) {
            switch $0 {
            case .success(let image):
              continuation.resume(returning: image)
            case .failure(let error):
              continuation.resume(throwing: error)
            }
          }
        }
    }
  }
}
