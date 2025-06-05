import Combine
import Foundation

/// 多語言前綴
///
/// 會自行監聽語言轉換
///
/// 並且執行`替換`掉所指定的 content
///
/// Situation:
///
///     需求的字串是自行組合, ex: "Test \(amount) \(crypto)"
///     其中 localization 只有 Test
///     當語言變更只需要替換掉Test
///
/// Usage:
///
///     直接先指定 content
///         @ReplaceableLocalizer(key: "abc")
///         var label = UILabel()
///
///     透過 replace 更新 content
///         @ReplaceableLocalizer
///         var label = UILabel()
///
///         _label.replace(by: LocalizationContentFactory.general(..., arguments: ...))
///
@propertyWrapper
final class ReplaceableLocalizer<T: Localizable>: LocalizationObserver {
    private var contents: [LocalizationContent] = []
    private var cancellable: AnyCancellable?

    var wrappedValue: T

    /// 單一狀態
    /// - Parameters:
    ///   - updateWhenInit: 是否需要先更新 localization
    init(wrappedValue: T,
         key: String,
         arguments: [String] = [],
         updateWhenInit: Bool = true) {
        defer {
            self.contents = LocalizationContentBuilder()
                .single(key, arguments: arguments)
                .contents

            if updateWhenInit {
                wrappedValue.updateLocalization(by: contents)
            }
        }

        self.wrappedValue = wrappedValue

        super.init()
    }

    /// - Parameters:
    ///   - updateWhenInit: 是否需要先更新 localization
    init(wrappedValue: T,
         contents: [LocalizationContent] = [],
         updateWhenInit: Bool = true) {
        self.contents = contents
        self.wrappedValue = wrappedValue

        if updateWhenInit {
            wrappedValue.updateLocalization(by: contents)
        }

        super.init()
    }

    /// 替換單一狀態 content
    func replace(key: String, arguments: [String] = []) {
        let previous = contents

        contents = LocalizationContentBuilder(provider: provider)
            .single(key, arguments: arguments)
            .contents

        wrappedValue.replaceLocalization(by: previous, by: contents)
    }

    func replace(by contents: [LocalizationContent]) {
        let previous = self.contents

        self.contents = contents

        wrappedValue.replaceLocalization(by: previous, by: contents)
    }

    override func handleLanguageChanged() {
        let previous = contents

        // 透過 refresh 去拿到當下語言的 content
        contents = contents.map { $0.refresh() }

        wrappedValue.replaceLocalization(by: previous, by: contents)
    }
}
