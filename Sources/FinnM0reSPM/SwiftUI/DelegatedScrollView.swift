import SwiftUI

private struct OffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) { }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value _: inout CGSize, nextValue _: () -> CGSize) { }
}

@available(iOS 14.0, *)
public struct DelegatedScrollView<Content: View>: View {
  private let spaceName = "DelegatedScrollView"

  let content: () -> Content
  let onOffsetChanged: ((CGFloat) -> Void)?
  let onBottomReached: (() -> Void)?

  @State var offsetY = CGFloat.zero
  @State var size = CGSize.zero
  @State var contentSize = CGSize.zero

  public init(
    @ViewBuilder content: @escaping () -> Content,
    onOffsetChanged: ((CGFloat) -> Void)? = nil,
    onBottomReached: (() -> Void)? = nil)
  {
    self.content = content
    self.onOffsetChanged = onOffsetChanged
    self.onBottomReached = onBottomReached
  }

  public var body: some View {
    ScrollView(showsIndicators: false) {
      offsetReader
      content()
        .readSize {
          contentSize = $0
        }
        .padding(.top, -8)
    }
    .readSize {
      size = $0
    }
    .coordinateSpace(name: spaceName)
    .onPreferenceChange(OffsetPreferenceKey.self) {
      offsetY = $0
      onOffsetChanged?($0)

      let scrollable = contentSize.height - size.height > 0 && size != .zero
      let bottomReached = -$0 >= contentSize.height - size.height
      if scrollable, bottomReached { onBottomReached?() }
    }
  }

  var offsetReader: some View {
    GeometryReader { proxy in
      Color.clear
        .preference(
          key: OffsetPreferenceKey.self,
          value: proxy.frame(in: .named(spaceName)).minY)
    }
    .frame(height: 0)
  }
}

@available(iOS 14.0, *)
extension View {
  fileprivate func readSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { proxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: proxy.size)
      })
      .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

@available(iOS 14.0, *)
struct DelegatedScrollView_Previews: PreviewProvider {
  struct Preview: View {
    @State var offset = CGFloat.zero

    var body: some View {
      DelegatedScrollView {
        LazyVStack {
          ForEach(0..<100) { index in
            Text("\(index)")
          }
        }
      } onOffsetChanged: {
        offset = $0
      } onBottomReached: {
        offset = -999
      }
      .overlay(
        Text("\n\n\n\n\(offset)"))
    }
  }

  static var previews: some View {
    Preview()
  }
}
