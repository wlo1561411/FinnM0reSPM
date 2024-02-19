import SwiftUI

@available(iOS 14.0, *)
public extension LazyImage {
    enum Phase {
        case placeholder
        case success(UIImage)
        case failure(Error)

        var image: UIImage? {
            switch self {
            case let .success(image):
                return image
            default:
                return nil
            }
        }

        var error: Error? {
            switch self {
            case let .failure(error):
                return error
            default:
                return nil
            }
        }
    }

    final class Repository: ObservableObject {
        @Published
        var phase: Phase?

        private let downloader: LazyImageDownloader

        init(downloader: LazyImageDownloader? = nil) {
            if let downloader {
                self.downloader = downloader
            } else {
                self.downloader = DefaultDownloader()
            }
        }

        @MainActor
        func image(from url: String) async {
            do {
                let image = try await downloader.image(from: url)
                phase = .success(image)
            } catch {
                phase = .failure(error)
            }
        }
    }
}
