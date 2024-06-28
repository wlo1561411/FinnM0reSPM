import Foundation

extension APILayer {
    public struct RetryDecision: APIDecision {
        public let leftCount: Int

        public init(leftCount: Int) {
            self.leftCount = leftCount
        }

        public func shouldApply(request _: some APIRequest, data _: Data, response: HTTPURLResponse) -> Bool {
            let isStatusCodeValid = (200..<300).contains(response.statusCode)
            return isStatusCodeValid == false && leftCount > 0
        }

        public func apply<Request: APIRequest>(
            request: Request,
            data _: Data,
            response _: HTTPURLResponse,
            done closure: @escaping (APIDecisionAction<Request>) -> Void)
        {
            let retryDecision = RetryDecision(leftCount: leftCount - 1)
            let newDecisions = request.decisions.replacing(self, with: retryDecision)
            closure(.restart(newDecisions))
        }
    }
}
