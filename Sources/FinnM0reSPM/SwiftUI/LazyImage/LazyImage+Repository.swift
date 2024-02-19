import SwiftUI

@available(iOS 14.0, *)
extension LazyImage {
    public enum Phase {
        case placeholder
        case success(UIImage)
        case failure(Error)

        var image: UIImage? {
            switch self {
            case .success(let image):
                return image
            default:
                return nil
            }
        }

        var error: Error? {
            switch self {
            case .failure(let error):
                return error
            default:
                return nil
            }
        }
    }

    public final class Repository: ObservableObject {
        @Published
        var phase: Phase?

        private let downloader: LazyImageDownloader

        init(downloader: LazyImageDownloader? = nil) {
            if let downloader {
                self.downloader = downloader
            }
            else {
                self.downloader = DefaultDownloader()
            }
        }

        @MainActor
        func image(from url: String) async {
            do {
                let image = try await downloader.image(from: url)
                phase = .success(image)
            }
            catch {
                phase = .failure(error)
            }
        }
    }
}
