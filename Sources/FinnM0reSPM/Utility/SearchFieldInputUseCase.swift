import UIKit

/// 搜尋輸入框規則
final class SearchFieldInputUseCase {
    /// 最多 20 個字符 (10 個中文字)
    private let maxCharacterCount = 20

    /// 字元正則
    private let allowedCharacterRegex = "^[\\p{Han}a-zA-Z0-9]*$"

    /// 請求搜尋最少字符
    private let requestMinimumCharacterCount = 2

    /// 搜尋點擊間隔
    private let requestTimeInterval: TimeInterval = 2

    /// 上次點擊請求時間
    private var lastRequestTime: TimeInterval = 0

    /// 處理文字輸入
    func shouldChangeCharacters(textField: UITextField,
                                in range: NSRange,
                                replacementString string: String)
        -> Bool {
        // 允許刪除
        if string.isEmpty {
            return true
        }

        guard let currentText = textField.text as NSString?
        else {
            return false
        }

        let newText = currentText.replacingCharacters(in: range, with: string)

        // 檢查是否為組字階段 (拼音輸入中)
        if textField.markedTextRange != nil {
            // 如果還在組字中, 不限制長度
            // 但若是候選字選擇階段, replacementString 很長, 此時要限制長度
            if string.count > 1 {
                return newText.count <= maxCharacterCount
            }
            return true
        }

        // 因為輸入剛開始注音時 `textField.markedTextRange` 不會有值
        // 沒辦法判斷是否在使用注音拼音
        // 所以使用判斷 `string`, 與游標位置處理
        if
            isSingleBopomofo(string),
            isCursorAtEndOfText(textField) {
            return true
        }

        // 長度限制
        if newText.count > maxCharacterCount {
            return false
        }

        // 正則判斷
        guard let regex = try? NSRegularExpression(pattern: allowedCharacterRegex)
        else {
            return false
        }

        let match = regex.firstMatch(in: string, range: .init(location: 0, length: string.utf16.count))

        return match != nil
    }

    /// 判斷是否能搜尋
    func shouldRequestSearch(currentText: String) throws -> Bool {
        if Date().timeIntervalSince1970 - lastRequestTime < requestTimeInterval {
            throw InputError.tappedTooFast
        } else {
            lastRequestTime = Date().timeIntervalSince1970
        }

        if currentText.count < requestMinimumCharacterCount {
            throw InputError.textNoEnough
        }

        return true
    }
}

// MARK: - Data Handle

extension SearchFieldInputUseCase {
    /// 判斷是否為單一注音
    private func isSingleBopomofo(_ string: String) -> Bool {
        let bopomofoRegex = "^[\\u3100-\\u312F\\u02C7\\u02CA\\u02CB]$"
        return string.range(of: bopomofoRegex, options: .regularExpression) != nil
    }

    /// 游標是否在文字末段
    private func isCursorAtEndOfText(_ textField: UITextField) -> Bool {
        guard let selected = textField.selectedTextRange
        else {
            return false
        }
        return selected.isEmpty && selected.end == textField.endOfDocument
    }
}

// MARK: - Error

extension SearchFieldInputUseCase {
    enum InputError: Error {
        case textNoEnough
        case tappedTooFast

        var description: String {
            switch self {
            case .textNoEnough:
                return "请输入二字以上的搜索内容"
            case .tappedTooFast:
                return "请求频率过快"
            }
        }
    }
}
