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

//===----------------------------------------------------------------------===//
// uniqued()
//===----------------------------------------------------------------------===//

extension Sequence where Element: Hashable {
    /// Returns an array with only  unique elements of this sequence, in the order of the first occurrence of each unique element.
    ///
    /// In this example, `uniqued()` is used to include only names which are
    /// unique
    ///
    ///     let animals = ["dog", "pig", "cat", "ox", "dog","cat"]
    ///     let uniqued = animals.uniqued()
    ///     print(uniqued)
    ///     // Prints "["dog", "pig","cat", "ox"]"`
    ///
    /// - Returns: Returns an array with only the unique elements of this sequence
    ///  .
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    public func uniqued() -> [Element] {
        var seen: Set<Element> = []
        var result: [Element] = []
        for element in self where seen.insert(element).inserted {
            result.append(element)
        }
        return result
    }
}

extension Sequence {
  
    /// Returns an array with the unique elements of this sequence (as determined
    /// by the given projection), in the order of the first occurrence of each
    /// unique element.
    ///
    /// In this example, `uniqued()` is used to include only names which are
    /// unique
    ///
    ///     let animals = ["dog", "pig", "cat", "ox", "dog","cat"]
    ///     let uniqued = animals.uniqued()
    ///     print(uniqued)
    ///     // Prints "["dog", "pig","cat", "ox"]"`
    ///
    /// - Parameter projection: A projecting closure. `projection` accepts an
    ///   element of this sequence as its parameter and returns a projected
    ///   value of the same  type.
    ///
    /// - Returns: Returns an array with only the unique elements of this sequence
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
  public func uniqued<Subject: Hashable>(
    on projection: (Element) throws -> Subject
  ) rethrows -> [Element] {
    var seen: Set<Subject> = []
    var result: [Element] = []
    for element in self  where seen.insert(try projection(element)).inserted{
        result.append(element)
    }
    return result
  }
}
