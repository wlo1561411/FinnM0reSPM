import UIKit

extension SlideView {
  class LRUCache<T> {
    let capacity: Int
    var keys: [String] = []
    var cacheDictionary: [String: T] = [:]

    init(size: Int) {
      self.capacity = size
    }
  }
}

extension SlideView.LRUCache {
  func set(object: T, for key: String) {
    if keys.contains(key) {
      cacheDictionary.updateValue(object, forKey: key)

      /// Change key's position by LRU
      keys.removeAll(where: { $0 == key })
      keys.append(key)
    }
    else {
      if keys.count < capacity {
        cacheDictionary.updateValue(object, forKey: key)
        keys.append(key)
      }
      /// The cache size had beyond capacity
      else {
        /// Need to remove the first object
        guard let frontKey = keys.first else { return }
        cacheDictionary.removeValue(forKey: frontKey)
        keys.removeFirst()

        cacheDictionary.updateValue(object, forKey: key)
        keys.append(key)
      }
    }
  }

  func object(for key: String) -> T? {
    if keys.contains(key) {
      /// Change key's position by LRU
      keys.removeAll(where: { $0 == key })
      keys.append(key)

      return cacheDictionary[key]
    }
    else { return nil }
  }

  func removeAll() {
    keys.removeAll()
    cacheDictionary.removeAll()
  }
}
