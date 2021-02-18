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

extension Sequence {
  /// Implementation for min(count:areInIncreasingOrder:)
  @inlinable
  internal func _minImplementation(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
    var iterator = makeIterator()
    
    var result: [Element] = []
    result.reserveCapacity(count)
    while result.count < count, let e = iterator.next() {
      result.append(e)
    }
    try result.sort(by: areInIncreasingOrder)
    
    while let e = iterator.next() {
      // To be part of `result`, `e` must be strictly less than `result.last`.
      guard try areInIncreasingOrder(e, result.last!) else { continue }
      let insertionIndex =
        try result.partitioningIndex { try areInIncreasingOrder(e, $0) }
      
      assert(insertionIndex != result.endIndex)
      result.removeLast()
      result.insert(e, at: insertionIndex)
    }

    return result
  }
  
  /// Implementation for max(count:areInIncreasingOrder:)
  @inlinable
  internal func _maxImplementation(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
    var iterator = makeIterator()
    
    var result: [Element] = []
    result.reserveCapacity(count)
    while result.count < count, let e = iterator.next() {
      result.append(e)
    }
    try result.sort(by: areInIncreasingOrder)
    
    while let e = iterator.next() {
      // To be part of `result`, `e` must be greater/equal to `result.first`.
      guard try !areInIncreasingOrder(e, result.first!) else { continue }
      let insertionIndex =
        try result.partitioningIndex { try areInIncreasingOrder(e, $0) }

      assert(insertionIndex > 0)
      // Inserting `e` and then removing the first element (or vice versa)
      // would perform a double shift, so we manually shift down the elements
      // before dropping `e` in.
      var i = 1
      while i < insertionIndex {
        result[i - 1] = result[i]
        i += 1
      }
      result[insertionIndex - 1] = e
    }
    
    return result
  }
  
  /// Returns the smallest elements of this sequence, as sorted by the given
  /// predicate.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.min(count: 3, sortedBy: <)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a sequence but only need to access its smallest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire sequence. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameters:
  ///   - count: The number of elements to return. If `count` is greater than
  ///     the number of elements in this sequence, all of the sequence's
  ///     elements are returned.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its
  ///     first argument should be ordered before its second argument;
  ///     otherwise, `false`.
  /// - Returns: An array of the smallest `count` elements of this sequence,
  ///   sorted according to `areInIncreasingOrder`.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   sequence and *k* is `count`.
  public func min(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
    precondition(count >= 0, """
      Cannot find a minimum with a negative count of elements!
      """
    )

    print("-------------------------------------")
    // Do nothing if we're prefixing nothing.
    guard count > 0 else {
      return []
    }

    return try _minImplementation(count: count, sortedBy: areInIncreasingOrder)
  }

  /// Returns the largets elements of this sequence, as sorted by the given
  /// predicate.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// largest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.max(count: 3, sortedBy: <)
  ///     // [7, 8, 9]
  ///
  /// If you need to sort a sequence but only need to access its largest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire sequence. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameters:
  ///   - count: The number of elements to return. If `count` is greater than
  ///     the number of elements in this sequence, all of the sequence's
  ///     elements are returned.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its
  ///     first argument should be ordered before its second argument;
  ///     otherwise, `false`.
  /// - Returns: An array of the largest `count` elements of this sequence,
  ///   sorted according to `areInIncreasingOrder`.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   sequence and *k* is `count`.
  public func max(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
    precondition(count >= 0, """
      Cannot find a maximum with a negative count of elements!
      """
    )

    // Do nothing if we're suffixing nothing.
    guard count > 0 else {
      return []
    }

    return try _maxImplementation(count: count, sortedBy: areInIncreasingOrder)
  }
}

extension Sequence where Element: Comparable {
  /// Returns the smallest elements of this sequence.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.min(count: 3)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a sequence but only need to access its smallest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire sequence. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The number of elements to return. If `count` is greater
  ///   than the number of elements in this sequence, all of the sequence's
  ///   elements are returned.
  /// - Returns: An array of the smallest `count` elements of this sequence.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   sequence and *k* is `count`.
  public func min(count: Int) -> [Element] {
    return min(count: count, sortedBy: <)
  }

  /// Returns the largest elements of this sequence.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// largest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.max(count: 3)
  ///     // [7, 8, 9]
  ///
  /// If you need to sort a sequence but only need to access its largest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire sequence. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The number of elements to return. If `count` is greater
  ///   than the number of elements in this sequence, all of the sequence's
  ///   elements are returned.
  /// - Returns: An array of the largest `count` elements of this sequence.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   sequence and *k* is `count`.
  public func max(count: Int) -> [Element] {
    return max(count: count, sortedBy: <)
  }
}

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
  /// If you need to sort a collection but only need to access its smallest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameters:
  ///   - count: The number of elements to return. If `count` is greater than
  ///     the number of elements in this collection, all of the collection's
  ///     elements are returned.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its
  ///     first argument should be ordered before its second argument;
  ///     otherwise, `false`.
  /// - Returns: An array of the smallest `count` elements of this collection,
  ///   sorted according to `areInIncreasingOrder`.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   collection and *k* is `count`.
  public func min(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
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
    
    return try _minImplementation(count: count, sortedBy: areInIncreasingOrder)
  }

  /// Returns the largets elements of this collection, as sorted by the given
  /// predicate.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// largest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.max(count: 3, sortedBy: <)
  ///     // [7, 8, 9]
  ///
  /// If you need to sort a collection but only need to access its largest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameters:
  ///   - count: The number of elements to return. If `count` is greater than
  ///     the number of elements in this collection, all of the collection's
  ///     elements are returned.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its
  ///     first argument should be ordered before its second argument;
  ///     otherwise, `false`.
  /// - Returns: An array of the largest `count` elements of this collection,
  ///   sorted according to `areInIncreasingOrder`.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   collection and *k* is `count`.
  public func max(
    count: Int,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
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

    return try _maxImplementation(count: count, sortedBy: areInIncreasingOrder)
  }
}

extension Collection where Element: Comparable {
  /// Returns the smallest elements of this collection.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.min(count: 3)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a collection but only need to access its smallest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The number of elements to return. If `count` is greater
  ///   than the number of elements in this collection, all of the collection's
  ///   elements are returned.
  /// - Returns: An array of the smallest `count` elements of this collection.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   collection and *k* is `count`.
  public func min(count: Int) -> [Element] {
    return min(count: count, sortedBy: <)
  }

  /// Returns the largest elements of this collection.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// largest values:
  ///
  ///     let numbers = [7, 1, 6, 2, 8, 3, 9]
  ///     let smallestThree = numbers.max(count: 3)
  ///     // [7, 8, 9]
  ///
  /// If you need to sort a collection but only need to access its largest
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The number of elements to return. If `count` is greater
  ///   than the number of elements in this collection, all of the collection's
  ///   elements are returned.
  /// - Returns: An array of the largest `count` elements of this collection.
  ///
  /// - Complexity: O(*k* log *k* + *nk*), where *n* is the length of the
  ///   collection and *k* is `count`.
  public func max(count: Int) -> [Element] {
    return max(count: count, sortedBy: <)
  }
}
