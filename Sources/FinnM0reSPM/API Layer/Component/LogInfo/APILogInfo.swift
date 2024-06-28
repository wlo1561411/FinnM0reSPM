import Foundation

public protocol APILogInfo {
    var request: URLRequest { get }

    var originalRequestDate: Date { get }
    var realRequestDate: Date { get }

    var responseDate: Date { get }

    var response: HTTPURLResponse? { get }
    var data: Data? { get }
    var error: Error? { get }
}
