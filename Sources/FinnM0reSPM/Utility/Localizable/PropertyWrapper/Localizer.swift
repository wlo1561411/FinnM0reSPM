import Combine
import Foundation

/// 多語言前綴
///
/// 會自行監聽語言轉換
///
/// 並且執行`全部`更新
///
/// Usage:
///
///     直接先指定 content
///         @Localizer(key: "abc")
///         var label = UILabel()
///
///     透過 update 更新 content
///         @Localizer
///         var label = UILabel()
///
///         _label.update(by: LocalizationContentFactory.general(..., arguments: ...))
///
@propertyWrapper
final class Localizer<T: Localizable>: LocalizationObserver {
    private var contents: [LocalizationContent] = []
    private var cancellable: AnyCancellable?

    var wrappedValue: T

    /// 單一狀態
    init(wrappedValue: T,
         key: String,
         arguments: [String] = []) {
        defer {
            self.contents = LocalizationContentBuilder()
                .single(key, arguments: arguments)
                .contents

            wrappedValue.updateLocalization(by: contents)
        }

        self.wrappedValue = wrappedValue

        super.init()
    }

    init(wrappedValue: T,
         contents: [LocalizationContent] = []) {
        self.contents = contents
        self.wrappedValue = wrappedValue

        wrappedValue.updateLocalization(by: contents)

        super.init()
    }

    /// 更新單一狀態 content
    func update(key: String, arguments: [String] = []) {
        contents = LocalizationContentBuilder(provider: provider)
            .single(key, arguments: arguments)
            .contents

        wrappedValue.updateLocalization(by: contents)
    }

    func update(by contents: [LocalizationContent]) {
        self.contents = contents

        wrappedValue.updateLocalization(by: contents)
    }

    override func handleLanguageChanged() {
        wrappedValue.updateLocalization(by: contents)
    }
}
