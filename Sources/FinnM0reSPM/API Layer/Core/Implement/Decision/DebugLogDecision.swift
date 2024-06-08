import Foundation
import OSLog

private let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    formatter.timeZone = .current
    return formatter
}()

extension APILayer {
    struct DebugLogDecision: APILogDecision {
        func shouldApply(request: some APIRequest, logInfo _: APILogInfo) -> Bool {
            #if DEBUG
                request.isEnableDebugLog
            #else
                false
            #endif
        }

        func apply(request _: some APIRequest, logInfo: APILogInfo) {
            var values: [String] = []

            values.append("")
            values.append("request Times: \(dateFormatter.string(from: logInfo.realRequestDate))")
            values.append("request: [\(logInfo.request.httpMethod ?? "")] \(logInfo.request.url?.absoluteString ?? "")")

            let headers = logInfo.request
                .allHTTPHeaderFields?
                .sorted(by: {
                    $0.key.uppercased() < $1.key.uppercased()
                })
                .map({
                    "\tkey: \($0.key)\n\t\tvalue: \($0.value)"
                }) ?? []

            values += headers

            if let httpBody = logInfo.request.httpBody {
                values.append("request body:")
                if let string = String(data: httpBody, encoding: .utf8) {
                    values.append(string)
                }
            }

            values.append("------------------------------")

            values.append("response Times: \(dateFormatter.string(from: logInfo.responseDate))")

            if let response = logInfo.response {
                values.append("response Path: \(response.url?.absoluteString ?? "")")
                values.append("response Code: [\(response.statusCode)]")
            }
            else {
                values.append("response Path: nil")
            }

            if let data = logInfo.data {
                values.append("response Data:")
                if let string = String(data: data, encoding: .utf8) {
                    values.append(string)
                }
            }

            if let error = logInfo.error {
                values.append("response Error:")
                values.append(error.localizedDescription)
            }

            values.append("")

            let message = values.joined(separator: "\n")

            if #available(iOS 14.0, *) {
                Logger().log(level: .info, "\(message)")
            }
            else {
                print(message)
            }
        }
    }
}
