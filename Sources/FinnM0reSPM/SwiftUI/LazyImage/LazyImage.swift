import SwiftUI

@available(iOS 14.0, *)
public struct LazyImage<Success, Placeholder, Failure>: View
  where
  Success: View,
  Placeholder: View,
  Failure: View
{
  @StateObject fileprivate var repository: Repository = .init()

  private let url: String

  private let success: (UIImage) -> Success
  private let placeholder: () -> Placeholder
  private let failure: (Error?) -> Failure

  private var haveFailureContent: Bool {
    !(failure(nil) is EmptyView)
  }

  private var havePlaceholderContent: Bool {
    !(placeholder() is EmptyView)
  }

  public init(
    url: String,
    downloader: LazyImageDownloader? = nil,
    @ViewBuilder success: @escaping (UIImage) -> Success,
    @ViewBuilder placeholder: @escaping () -> Placeholder = { EmptyView() },
    @ViewBuilder failure: @escaping (Error?) -> Failure = { _ in EmptyView() })
  {
    self.url = url
    self.success = success
    self.placeholder = placeholder
    self.failure = failure

    if let downloader {
      self._repository = .init(wrappedValue: .init(downloader: downloader))
    }
  }

  public var body: some View {
    VStack {
      switch repository.phase {
      case .success(let image):
        success(image)

      case .failure(let error):
        failure(error)

      case .placeholder:
        placeholder()

      default:
        if havePlaceholderContent {
          placeholder()
        }
        else { Color.clear }
      }
    }
    .if(!haveFailureContent) {
      $0.visibility(repository.phase?.error == nil ? .visible : .gone)
    }
    .onAppear {
      Task {
        await repository.image(from: url)
      }
    }
  }
}

// FIXME: XCode 14.2 will crash
@available(iOS 14.0, *)
struct LazyImage_Previews: PreviewProvider {
  static var previews: some View {
    LazyImage(
      url: "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/store-card-14-16-mac-nav-202301?wid=200&hei=130&fmt=png-alpha&.v=1670959891635",
      success: {
        Image(uiImage: $0)
          .resizable()
          .scaledToFit()
      },
      placeholder: {
        Text("Loading")
      },
      failure: { _ in
        Image("Failed")
          .resizable()
          .scaledToFit()
      })
      .frame(width: 300, height: 300)
      .backgroundColor(.darkGray)

    LazyImage(
      url: "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/store-card-14-16-mac-nav-202301?wid=200&hei=130&fmt=png-alpha&.v=1670959891635",
      success: {
        Image(uiImage: $0)
          .resizable()
          .scaledToFit()
      },
      failure: { _ in
        Image("Failed")
          .resizable()
          .scaledToFit()
      })
      .frame(width: 300, height: 300)
      .backgroundColor(.darkGray)

    HStack {
      LazyImage(
        url: "hts",
        success: {
          Image(uiImage: $0)
            .resizable()
            .scaledToFit()
        })
        .frame(width: 300, height: 300)
        .backgroundColor(.darkGray)
    }
  }
}
