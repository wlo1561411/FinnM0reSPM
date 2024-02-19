import XCTest

@testable import FinnM0reSPM

/// To catch data races remove @ThreadSafe property wrappers and enable thread sanitizer for tests in scheme editor
final class ModifyTests: XCTestCase {
    private struct ComplexStruct: Equatable {
        struct InnerStruct: Equatable {
            var a: Int = .zero
            var b: Int = .zero
        }

        var c: Int = .zero
        var x: InnerStruct = .init()
    }

    private final class ComplexClass: Equatable {
        final class InnerClass: Equatable {
            @ThreadSafe
            var a: Int = .zero

            @ThreadSafe
            var b: Int = .zero

            static func == (lhs: InnerClass, rhs: InnerClass) -> Bool {
                lhs.a == rhs.a && lhs.b == rhs.b
            }
        }

        @ThreadSafe
        var c: Int = .zero

        var x: InnerClass = .init()

        static func == (lhs: ComplexClass, rhs: ComplexClass) -> Bool {
            lhs.c == rhs.c && lhs.x == rhs.x
        }
    }

    @ThreadSafe
    private var structValue = ComplexStruct()

    @ThreadSafe
    private var classValue = ComplexClass()

    @ThreadSafe
    private var arrayValue: [Int] = []

    private func modifyComplexStruct() {
        _ = structValue.c
        _ = structValue.x.a
        _ = structValue.x.b

        structValue.x.a += 5

        if Bool.random() {
            structValue.c = .random(in: 0...1000)
        }
        else {
            if Bool.random() {
                structValue.x.a = .random(in: 0...1000)
            }
            else {
                structValue.x.b = .random(in: 0...1000)
            }
        }

        structValue.c += 1
        structValue.x.b += 1
        structValue.x.a += 1
    }

    override func setUp() {
        super.setUp()

        structValue = .init()
        classValue = .init()
    }

    func testStructReadWriteMeasure() {
        let initialValue = structValue

        // _read = 0.348
        // get = 0.319

        measure {
            for _ in 0..<100_000 {
                if Bool.random() {
                    self.structValue.x.a = .random(in: 0...1000)
                }
                else {
                    self.structValue.x.b = .random(in: 0...1000)
                }

                self.structValue.c = self.structValue.x.b + self.structValue.x.a
            }
        }

        XCTAssertNotEqual(structValue, initialValue)
    }

    func testStructMultiThreadReadWrite() {
        let initialValue = structValue

        DispatchQueue.concurrentPerform(iterations: 10000) { _ in
            self.modifyComplexStruct()
        }

        XCTAssertNotEqual(structValue, initialValue)
    }

    func testStructMultiTaskReadWrite() async {
        let initialValue = structValue

        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 1..<10000 {
                group.addTask {
                    try await Task.sleep(nanoseconds: .random(in: 10_000_000..<200_000_000))
                    return self.modifyComplexStruct()
                }
            }
        }

        XCTAssertNotEqual(structValue, initialValue)
    }

    func testClassReadWrite() {
        let initialValue = classValue

        DispatchQueue.concurrentPerform(iterations: 10000) { _ in
            _ = self.classValue.c
            _ = self.classValue.x.a
            _ = self.classValue.x.b

            if Bool.random() {
                self.classValue.c = .random(in: 0...1000)
            }
            else {
                if Bool.random() {
                    self.classValue.x.a = .random(in: 0...1000)
                }
                else {
                    self.classValue.x.b = .random(in: 0...1000)
                }
            }

            self.classValue.c += 1
            self.classValue.x.b += 1
            self.classValue.x.a += 1
        }

        XCTAssertEqual(classValue, initialValue)
    }

    func testArrayReadWrite() {
        let initialValue = arrayValue

        DispatchQueue.concurrentPerform(iterations: 10000) { _ in
            _ = self.arrayValue

            if Bool.random() {
                self.arrayValue.removeAll {
                    $0 % 2 == 0
                }
            }
            else {
                for _ in 0..<20 {
                    self.arrayValue.append(.random(in: 0...10))
                }
            }

            self.arrayValue = self.arrayValue.map {
                $0 * 2
            }
        }

        XCTAssertNotEqual(arrayValue, initialValue)
    }
}
