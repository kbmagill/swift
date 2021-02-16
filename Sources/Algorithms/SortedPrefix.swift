//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the smallest elements of this collection, as sorted by the given
  /// predicate.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.min(count: 3, sortedBy: <)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a collection but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The number of elements to prefix.
  /// - Parameter areInIncreasingOrder: A predicate that returns true if its
  /// first argument should be ordered before its second argument;
  /// otherwise, false.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   collection and *k* is `count`.
  public func min(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Self.Element] {
    precondition(count >= 0, """
      Cannot find a minimum with a negative count of elements!
      """
    )

    // Do nothing if we're prefixing nothing.
    guard count > 0 else {
      return []
    }

    // Make sure we are within bounds.
    let prefixCount = Swift.min(count, self.count)

    // If we're attempting to prefix more than 10% of the collection, it's
    // faster to sort everything.
    guard prefixCount < (self.count / 10) else {
      return Array(try sorted(by: areInIncreasingOrder).prefix(prefixCount))
    }

    var result = try self.prefix(prefixCount).sorted(by: areInIncreasingOrder)
    for e in self.dropFirst(prefixCount) {
      // To continue, `e` must be strictly less than `result.last`.
      guard try areInIncreasingOrder(e, result.last!) else {
        continue
      }
      let insertionIndex =
        try result.partitioningIndex { try areInIncreasingOrder(e, $0) }
      result.removeLast()
      result.insert(e, at: insertionIndex)
    }

    return result
  }

  public func max(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Self.Element] {
    precondition(count >= 0, """
      Cannot find a maximum with a negative count of elements!
      """
    )

    // Do nothing if we're suffixing nothing.
    guard count > 0 else {
      return []
    }

    // Make sure we are within bounds.
    let suffixCount = Swift.min(count, self.count)

    // If we're attempting to prefix more than 10% of the collection, it's
    // faster to sort everything.
    guard suffixCount < (self.count / 10) else {
      return Array(try sorted(by: areInIncreasingOrder).suffix(suffixCount))
    }

    var result = try self.prefix(suffixCount).sorted(by: areInIncreasingOrder)
    for e in self.dropFirst(suffixCount) {
      // To continue, `e` must be greater than or equal to `result.first`.
      guard try !areInIncreasingOrder(e, result.first!) else { continue }
      let insertionIndex =
        try result.partitioningIndex { try areInIncreasingOrder(e, $0) }
      if insertionIndex == result.endIndex {
        result.removeFirst()
        result.append(e)
      } else {
        // Inserting `e` and then removing the first element (or vice versa)
        // would do a double shift, so we manually shift down the elements
        // before dropping `e` in.
        var i = 0
        while i < insertionIndex {
          result[i] = result[i + 1]
          i += 1
        }
        result[insertionIndex] = e
      }
    }

    return result
  }
}

extension Collection where Element: Comparable {
  /// Returns the first k elements of this collection when it's sorted in
  /// ascending order.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.min(count: 3)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a collection but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The k number of elements to prefix.
  ///
  /// - Complexity: O(k log k + nk)
  public func min(count: Int) -> [Element] {
    return min(count: count, sortedBy: <)
  }
}
