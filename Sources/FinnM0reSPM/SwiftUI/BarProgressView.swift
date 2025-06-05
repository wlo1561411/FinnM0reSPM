import SwiftUI

@available(iOS 14.0, *)
public struct BarProgressView: View {
    @State
    private var currentProgress = 0.0

    let ratio: Double
    let duration: Double

    public init(to ratio: Double, duration: Double = 0.3) {
        self.ratio = ratio
        self.duration = duration
    }

    public var body: some View {
        GeometryReader { proxy in
            let full = proxy.frame(in: .global).width
            let numbersOfBar = Int(full / 6)

            VStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.from(.gray))
                        .frame(width: full)

                    Rectangle()
                        .foregroundColor(.from(.systemGreen))
                        .frame(width: full * currentProgress)
                }
                .mask(
                    HStack(spacing: 2) {
                        ForEach(0..<numbersOfBar, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .frame(width: 4)
                        }
                    })
            }
        }
        .onChange(of: ratio) { newValue in
            withAnimation(.linear(duration: duration)) {
                self.currentProgress = newValue
            }
        }
    }
}

@available(iOS 14.0, *)
struct BarProgressView_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var ratio: Double = 0

        var body: some View {
            VStack {
                BarProgressView(to: ratio, duration: 3)
                    .frame(width: .infinity, height: 30)
            }
            .onAppear {
                ratio = 0.5
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
