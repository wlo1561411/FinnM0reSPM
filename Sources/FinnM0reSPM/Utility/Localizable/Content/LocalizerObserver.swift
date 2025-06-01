import Combine

class LocalizerObserver {
    private var cancellable: AnyCancellable?

    init() {
        self.cancellable = MockLocalizableBridge.shared
            .onLanguageChanged
            .sink { [weak self] in
                self?.handleLanguageChanged()
            }
    }

    deinit {
        cancellable?.cancel()
        cancellable = nil
    }

    func handleLanguageChanged() { }
}
