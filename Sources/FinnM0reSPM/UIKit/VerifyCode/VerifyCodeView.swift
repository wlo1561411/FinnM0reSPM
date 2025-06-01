import SnapKit
import UIKit

public final class VerifyCodeView: UIView {
    public struct ColorPattern {
        var backgroundColor: UIColor
        var cornerRadius: CGFloat
        var borderColor: UIColor
        var borderHighlightColor: UIColor
        var borderWidth: CGFloat
        var textColor: UIColor
        var textFont: UIFont
        var cursorColor: UIColor
    }

    private let textField = UITextField()
    private let codeStackView = UIStackView()

    private var inputSquares: [Square] = []

    private var codeLength = 0

    private let colorPattern: VerifyCodeView.ColorPattern
    private let itemSpacing: CGFloat

    @Bindable
    private(set) var onCompleted = ""

    public init(
        colorPattern: VerifyCodeView.ColorPattern,
        itemSpacing: CGFloat)
    {
        self.colorPattern = colorPattern
        self.itemSpacing = itemSpacing

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reload(length: Int) {
        codeLength = length

        makeCodeInputView()
        clear()
    }

    public func clear() {
        textField.text = ""
        updateSquare("")
    }
}

extension VerifyCodeView {
    private func setupUI() {
        textField.tintColor = .clear
        textField.backgroundColor = .clear
        textField.textColor = .clear
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .no
        textField.smartInsertDeleteType = .no
        textField.delegate = self
        textField.addTarget(self, action: #selector(onEditingChanged), for: .editingChanged)

        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        codeStackView.backgroundColor = .clear
        codeStackView.axis = .horizontal
        codeStackView.distribution = .fillEqually
        codeStackView.spacing = itemSpacing
        codeStackView.alignment = .fill

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCodeStackClicked))
        codeStackView.addGestureRecognizer(tapGesture)

        addSubview(codeStackView)
        codeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func makeCodeInputView() {
        codeStackView.removeAllFully()
        inputSquares.removeAll()

        for i in 0..<codeLength {
            let view = Square(colorPattern)
            view.tag = i

            inputSquares.append(view)

            codeStackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.width.equalTo(view.snp.height)
            }
        }
    }

    private func updateSquare(_ text: String?) {
        guard let text
        else {
            for inputSquare in inputSquares {
                inputSquare.isHighlighted = false
            }
            return
        }

        let array = text.map { String($0) }

        inputSquares
            .enumerated()
            .forEach { key, value in
                value.updateUI(
                    with: array[safe: key] ?? "",
                    isHighlighted: key == array.count)
            }
    }

    @objc
    private func onCodeStackClicked() {
        textField.becomeFirstResponder()
    }

    @objc
    private func onEditingChanged() {
        guard let text = textField.text else { return }

        updateSquare(text)

        if text.count == codeLength {
            textField.resignFirstResponder()
            onCompleted = text
        }
    }
}

extension VerifyCodeView: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String)
        -> Bool
    {
        guard
            let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText)
        else {
            return false
        }

        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count

        return count <= codeLength
    }
}
