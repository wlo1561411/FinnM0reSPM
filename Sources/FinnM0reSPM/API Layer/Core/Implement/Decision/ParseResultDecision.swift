import Foundation

private let decoder = JSONDecoder()

extension APILayer {
    struct ParseResultDecision: APIDecision {
        func shouldApply(request _: some APIRequest, data _: Data, response _: HTTPURLResponse) -> Bool {
            true
        }

        func apply<Request: APIRequest>(
            request _: Request,
            data: Data,
            response _: HTTPURLResponse,
            done closure: @escaping (APIDecisionAction<Request>) -> Void)
        {
            do {
                let value = try decoder.decode(Request.Response.self, from: data)
                closure(.done(value))
            }
            catch {
                closure(.error(error))
            }
        }
    }
}
