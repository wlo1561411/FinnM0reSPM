import SwiftUI

@available(iOS 14.0, *)
public struct UIKitTextField: UIViewRepresentable {
  @Binding var text: String
  @Binding var isFirstResponder: Bool
  @Binding var showPassword: Bool

  private let isPasswordType: Bool
  private let inputType: any InputType

  private var configuration = { (_: UITextField) in }

  public init(
    text: Binding<String>,
    isFirstResponder: Binding<Bool>,
    showPassword: Binding<Bool>,
    isPasswordType: Bool,
    inputType: some InputType,
    configuration: @escaping (UITextField) -> Void = { (_: UITextField) in })
  {
    self._text = text
    self._isFirstResponder = isFirstResponder
    self._showPassword = showPassword

    self.isPasswordType = isPasswordType
    self.inputType = inputType
    self.configuration = configuration
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      $text,
      $isFirstResponder,
      inputType)
  }

  public func makeUIView(context: Context) -> UITextField {
    let view = PasteableTextField()

    view.text = text
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    configuration(view)
    
    inputType.functionalConfig(view)

    view.addTarget(context.coordinator, action: #selector(context.coordinator.textEditChanged), for: .editingChanged)
    view.addTarget(context.coordinator, action: #selector(context.coordinator.textEditEnd), for: .editingDidEnd)
    view.addTarget(context.coordinator, action: #selector(context.coordinator.textEditEnd), for: .editingDidEndOnExit)

    return view
  }

  public  func updateUIView(_ uiView: UITextField, context _: Context) {
    uiView.isSecureTextEntry = isPasswordType && !showPassword
    uiView.text = text

    switch isFirstResponder {
    case true:
      DispatchQueue.main.async {
        uiView.becomeFirstResponder()
      }
    case false:
      DispatchQueue.main.async {
        uiView.resignFirstResponder()
      }
    }
  }

  public class Coordinator: NSObject {
    @Binding private var text: String
    @Binding private var isFirstResponder: Bool

    private let inputType: any InputType

    lazy var oldText: String = text

    init(
      _ text: Binding<String>,
      _ isFirstResponder: Binding<Bool>,
      _ inputType: some InputType)
    {
      self._text = text
      self._isFirstResponder = isFirstResponder
      self.inputType = inputType
    }

    @objc
    func textEditChanged(_ sender: UITextField) {
      if
        let markedRange = sender.markedTextRange,
        sender.position(from: markedRange.start, offset: 0) != nil
      {
        return
      }

      guard let newText = sender.text?.halfWidth else { return }

      inputType.format(oldText, newText, $text)
      
      sender.sr.remainCursor(to: newText)
      
      oldText = text
    }

    @objc
    func textEditEnd(_: UITextField) {
      isFirstResponder = false

      inputType.onEditEnd($text)
    }
  }
}
