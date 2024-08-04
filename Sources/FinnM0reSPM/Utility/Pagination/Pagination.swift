import Foundation

protocol CountablePaged {
    var pageNum: Int { get }
    var isLastPage: Bool { get }
}

class Pagination<T: AutoCodable & CountablePaged> {
    private let initPage: Int
    private(set) var currentPage = 0
    private(set) var pageSize: Int
    private(set) var isLastPage = false
    private(set) var isLoading = false
    private(set) var response: T?

    private var fetching: ((Int, Int, @escaping (Result<T, Error>) -> Void) -> Void)?
    private var onSuccess: ((T) -> Void)?
    private var onError: ((Error) -> Void)?

    init(
        page: Int = 1,
        pageSize: Int = 20)
    {
        self.pageSize = pageSize
        self.initPage = page
    }

    func setup(
        fetching: ((Int, Int, @escaping (Result<T, Error>) -> Void) -> Void)?,
        onSuccess: ((T) -> Void)?,
        onError: ((Error) -> Void)?)
    {
        self.fetching = fetching
        self.onSuccess = onSuccess
        self.onError = onError
    }

    func reload() {
        guard !isLoading
        else {
            print("\(self) 正在請求")
            return
        }
        
        currentPage = initPage
        loadPage(page: currentPage)
    }

    func next() {
        guard !isLoading
        else {
            print("\(self) 正在請求")
            return
        }

        guard !isLastPage
        else {
            print("\(self) 已經是最後一頁了 page: \(currentPage)")
            return
        }

        let page: Int

        if currentPage == 0 {
            page = initPage
        }
        else {
            page = currentPage + 1
        }

        loadPage(page: page)
    }

    private func loadPage(page: Int) {
        isLoading = true

        fetching?(page, pageSize) { [weak self] result in
            guard let self else { return }

            isLoading = false

            switch result {
            case .success(let response):
                self.response = response
                currentPage = response.pageNum
                isLastPage = response.isLastPage
                onSuccess?(response)

            case .failure(let error):
                onError?(error)
            }
        }
    }
}
