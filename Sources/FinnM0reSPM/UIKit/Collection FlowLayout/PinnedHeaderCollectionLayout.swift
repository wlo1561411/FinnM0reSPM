import UIKit

public class PinnedHeaderCollectionLayout: UICollectionViewFlowLayout {
    // 應被固定標頭的分區索引。
    private let pinnedSectionIndex: Int

    public init(pinnedSectionIndex: Int) {
        self.pinnedSectionIndex = pinnedSectionIndex
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 覆寫此方法以修改給定矩形中所有元素（單元格、標頭、頁腳）的布局屬性。
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var origin = super.layoutAttributesForElements(in: rect), let collectionView else { return nil }

        // 為我們要固定的標頭定義特定的索引路徑。
        let indexPath = IndexPath(item: 0, section: pinnedSectionIndex)
        // 獲取指定標頭的布局屬性。
        let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        // 如果找到標頭的屬性，將其加入到布局屬性陣列中。
        if let attributes {
            origin.append(attributes)
        }

        // 遍歷所有布局屬性來檢查和修改應被固定的分區標頭。
        for attributes in origin {
            // 檢查該屬性是否為固定分區的標頭。
            if
                attributes.representedElementKind == UICollectionView.elementKindSectionHeader,
                attributes.indexPath.section == pinnedSectionIndex
            {
                // 計算該分區中的項目數。
                let numberOfItemsInSection = collectionView.numberOfItems(inSection: attributes.indexPath.section)
                // 定義該分區第一個項目的索引路徑。
                let firstItemIndexPath = IndexPath(item: 0, section: attributes.indexPath.section)
                var firstItemAttributes: UICollectionViewLayoutAttributes?

                // 如果分區有項目，獲取第一個項目的布局屬性；如果沒有，創建新的布局屬性。
                if numberOfItemsInSection > 0 {
                    firstItemAttributes = layoutAttributesForItem(at: firstItemIndexPath)
                }
                else {
                    firstItemAttributes = UICollectionViewLayoutAttributes()
                    let y = attributes.frame.maxY + sectionInset.top
                    firstItemAttributes?.frame = CGRect(x: 0, y: y, width: 0, height: 0)
                }

                // 確保有有效的第一個項目屬性。
                guard let firstItemAttributes else { return origin }

                // 計算標頭的新位置，確保它隨著滾動停留在可視範圍內。
                var rect = attributes.frame

                let offset = collectionView.contentOffset.y
                let headerY = firstItemAttributes.frame.origin.y - rect.height - sectionInset.top
                let maxY = max(offset, headerY)

                rect.origin.y = maxY

                attributes.frame = rect
                attributes.zIndex = 20
            }
        }
        return origin
    }

    // 覆寫此方法以在視圖範圍更改時使布局無效，這是實現標頭固定效果所必需的。
    public override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }
}

#if swift(>=5.9)
    @available(iOS 17.0, *)
    class PinnedHeaderCollectionLayoutDemo: UIViewController, UICollectionViewDataSource {
        class Cell: UICollectionViewCell {
            let label = UILabel()
            override init(frame: CGRect) {
                super.init(frame: frame)
                label.sr
                    .add(to: contentView)
                    .makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
            }

            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }

        let list = UICollectionView(frame: .zero, collectionViewLayout: PinnedHeaderCollectionLayout(pinnedSectionIndex: 2))

        override func viewDidLoad() {
            super.viewDidLoad()
            list.sr
                .register(Cell.self, identifier: "cell")
                .register(UICollectionReusableView.self, type: .header, identifier: "header")
                .dataSource(self)
                .add(to: view)
                .makeConstraints { make in
                    make.top.equalTo(view.snp.topMargin)
                    make.bottom.leading.trailing.equalToSuperview()
                }

            let layout = list.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 50)
            layout.headerReferenceSize = .init(width: UIScreen.main.bounds.width, height: 20)
        }

        func numberOfSections(in _: UICollectionView) -> Int {
            10
        }

        func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
            5
        }

        func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind _: String,
            at indexPath: IndexPath)
            -> UICollectionReusableView
        {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "header",
                for: indexPath)
            view.backgroundColor = indexPath.section == 0 ? .systemPink : .darkGray
            return view
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
            cell.label.text = "index \(indexPath.row)"
            return cell
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        PinnedHeaderCollectionLayoutDemo()
    }
#endif
