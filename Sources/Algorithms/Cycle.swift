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

/// A collection wrapper that repeats the elements of a base collection.
public struct Cycle<Base: Collection> {
  /// The collection to repeat.
  public let base: Base
  
  @usableFromInline
  internal init(base: Base) {
    self.base = base
  }
}

extension Cycle: Sequence {
  /// The iterator for a `Cycle` sequence.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    let base: Base
    
    @usableFromInline
    var current: Base.Index
    
    @usableFromInline
    internal init(base: Base) {
      self.base = base
      self.current = base.startIndex
    }
    
    @inlinable
    public mutating func next() -> Base.Element? {
      guard !base.isEmpty else { return nil }
      
      if current == base.endIndex {
        current = base.startIndex
      }
      
      defer { base.formIndex(after: &current) }
      return base[current]
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: base)
  }
}

extension Cycle: LazySequenceProtocol where Base: LazySequenceProtocol {}


/// A collection wrapper that repeats the elements of a base collection for a
/// finite number of times.
public struct FiniteCycle<Base: Collection> {
  /// A Product2 instance for iterating the Base collection.
  public let product: Product2<Range<Int>, Base>

  @usableFromInline
  internal init(base: Base, times: Int) {
    self.product = Product2(0..<times, base)
  }
}

extension FiniteCycle {
  /// The iterator for a `FiniteCycle` sequence.
  public struct Iterator : IteratorProtocol {
    @usableFromInline
    var productIterator: Product2<Range<Int>, Base>.Iterator

    @usableFromInline
    internal init(product: Product2<Range<Int>, Base>) {
      self.productIterator = product.makeIterator()
    }

    @inlinable
    public mutating func next() -> Base.Element? {
      self.productIterator.next()?.element2
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    return Iterator(product: product)
  }
}

extension FiniteCycle: LazySequenceProtocol, LazyCollectionProtocol
  where Base: LazyCollectionProtocol { }

extension FiniteCycle: Collection {

  public typealias Index = Product2<Range<Int>, Base>.Index

  @inlinable
  public var count: Int {
    product.count
  }

  @inlinable
  public var startIndex: Index {
    product.startIndex
  }

  @inlinable
  public var endIndex: Index {
    product.endIndex
  }

  @inlinable
  public subscript(_ index: Index) -> Element {
    product[index].element2
  }

  @inlinable
  public func index(after i: Index) -> Index {
    product.index(after: i)
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    product.distance(from: start, to: end)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    product.index(i, offsetBy: distance)
  }

  @inlinable
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    product.index(i, offsetBy: distance, limitedBy: limit)
  }
}

extension FiniteCycle: BidirectionalCollection
  where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    product.index(before: i)
  }
}

extension FiniteCycle: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension FiniteCycle: Equatable where Base: Equatable {}
extension FiniteCycle: Hashable where Base: Hashable {}

//===----------------------------------------------------------------------===//
// cycled()
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a sequence that repeats the elements of this collection forever.
  ///
  /// Use the `cycled()` method to repeat the elements of a sequence or
  /// collection forever. You can combine `cycled()` with another, finite
  /// sequence to iterate over the two together.
  ///
  ///     for (evenOrOdd, number) in zip(["even", "odd"].cycled(), 0..<10) {
  ///         print("\(number) is \(evenOrOdd)")
  ///     }
  ///     // 0 is even
  ///     // 1 is odd
  ///     // 2 is even
  ///     // 3 is odd
  ///     // ...
  ///     // 9 is odd
  ///
  /// - Important: When called on a non-empty collection, the resulting sequence
  ///   is infinite. Do not directly call methods that require a finite
  ///   sequence, like `map` or `filter`, without first constraining the length
  ///   of the cycling sequence.
  ///
  /// - Returns: A sequence that repeats the elements of this collection
  ///   forever.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func cycled() -> Cycle<Self> {
    Cycle(base: self)
  }
  
  /// Returns a sequence that repeats the elements of this collection the
  /// specified number of times.
  ///
  /// Passing `1` as `times` results in this collection's elements being
  /// provided a single time; passing `0` results in an empty sequence. The
  /// `print(_:)` function in this example is never called:
  ///
  ///     for x in [1, 2, 3].cycled(times: 0) {
  ///         print(x)
  ///     }
  ///
  /// - Parameter times: The number of times to repeat this sequence. `times`
  ///   must be zero or greater.
  /// - Returns: A sequence that repeats the elements of this sequence `times`
  ///   times.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func cycled(times: Int) -> FiniteCycle<Self> {
    FiniteCycle(base: self, times: times)
  }
}
