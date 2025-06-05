import Combine

class LocalizationObserver {
    let provider: LocalizationProvider

    private var cancellable: AnyCancellable?

    init(provider: LocalizationProvider = LocalizationServiceContext.shared) {
        self.provider = provider
        self.cancellable = provider
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
