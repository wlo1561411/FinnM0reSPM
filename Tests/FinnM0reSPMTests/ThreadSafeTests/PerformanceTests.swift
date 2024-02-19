import XCTest

@testable import FinnM0reSPM

final class PerformanceTests: XCTestCase {
    private enum Constants {
        static let iterations = 100_000
    }

    private struct ComplexStruct: Equatable {
        struct InnerStruct: Equatable {
            var a: Int = .zero
            var b: Int = .zero
        }

        var c: Int = .zero
        var x: InnerStruct = .init()

        mutating func modify() {
            _ = c
            _ = x.a
            _ = x.b

            if Bool.random() {
                c = .random(in: 0...1000)
            }
            else {
                if Bool.random() {
                    x.a = .random(in: 0...1000)
                }
                else {
                    x.b = .random(in: 0...1000)
                }
            }

            c += 1
            x.b += 1
            x.a += 1
        }
    }

    func testGCD() {
        var value = ComplexStruct()

        let queue = DispatchQueue(label: "test_queue")

        let t1 = Date()

        for _ in 0..<Constants.iterations {
            _ = queue.sync {
                value
            }

            queue.async {
                value.modify()
            }
        }

        let t2 = Date()
        print("1️⃣", t2.timeIntervalSince(t1))
    }

    func testActor() async {
        actor Value {
            private var value = ComplexStruct()

            @discardableResult
            func read() -> ComplexStruct {
                value
            }

            func update() {
                value.modify()
            }
        }

        let a = Value()

        let t1 = Date()

        for _ in 0..<Constants.iterations {
            _ = await a.read()
            await a.update()
        }

        let t2 = Date()
        print("2️⃣", t2.timeIntervalSince(t1))
    }
}
