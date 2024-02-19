import UIKit

extension Styler where Base: UITableView {
    @discardableResult
    public func register<Cell: UITableViewCell>(
        _ cell: Cell.Type,
        identifier: String = "\(Cell.self)")
        -> Self
    {
        base.register(cell.self, forCellReuseIdentifier: identifier)
        return self
    }

    @discardableResult
    public func register<Supplementary: UITableViewHeaderFooterView>(
        _ supplementary: Supplementary.Type,
        identifier: String = "\(Supplementary.self)")
        -> Self
    {
        base.register(supplementary.self, forHeaderFooterViewReuseIdentifier: identifier)
        return self
    }
}
