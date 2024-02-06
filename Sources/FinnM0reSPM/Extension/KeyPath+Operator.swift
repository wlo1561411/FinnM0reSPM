import Foundation

func == <Structure, Value: Equatable>(
    lhs: KeyPath<Structure, Value>,
    rhs: Value)
    -> (Structure) -> Bool
{
    { $0[keyPath: lhs] == rhs }
}

func >= <Structure, Value: Comparable>(
    lhs: KeyPath<Structure, Value>,
    rhs: Value)
    -> (Structure) -> Bool
{
    { $0[keyPath: lhs] >= rhs }
}

func <= <Structure, Value: Comparable>(
    lhs: KeyPath<Structure, Value>,
    rhs: Value)
    -> (Structure) -> Bool
{
    { $0[keyPath: lhs] <= rhs }
}

func > <Structure, Value: Comparable>(
    lhs: KeyPath<Structure, Value>,
    rhs: Value)
    -> (Structure) -> Bool
{
    { $0[keyPath: lhs] > rhs }
}

func < <Structure, Value: Comparable>(
    lhs: KeyPath<Structure, Value>,
    rhs: Value)
    -> (Structure) -> Bool
{
    { $0[keyPath: lhs] < rhs }
}

func ~= <Structure, Value: Comparable>(
    lhs: KeyPath<Structure, Value>,
    rhs: (Value, Value))
    -> (Structure) -> Bool
{
    { $0[keyPath: lhs] >= rhs.0 && $0[keyPath: lhs] <= rhs.1 }
}
