# First Delta

[[Source](../Sources/Algorithms/FirstDelta.swift) | 
 [Tests](../Tests/SwiftAlgorithmsTests/FirstDeltaTests.swift)]

Methods for finding the first place that two sequences differ.

The methods for finding the differences in sequences can be viewed as the
common core operation for the Standard Library's `elementsEqual(_: by:)` and
`starts(with: by:)` methods.

(To-do: expand on this.)

## Detailed Design

The element-returning methods are declared as extensions to `Sequence`.  The
overloads that default comparisons to the standard equality operator are
constrained to when the sources share the same `Element` type and said type
conforms to `Equatable`.

```swift
extension Sequence {
   func firstDelta<PossibleMirror: Sequence>(
       against possibleMirror: PossibleMirror,
       by areEquivalent: (Element, PossibleMirror.Element) throws -> Bool
   ) rethrows -> (Element?, PossibleMirror.Element?)
}

extension Sequence where Element: Equatable {
    func firstDelta<PossibleMirror: Sequence>(
        against possibleMirror: PossibleMirror
    ) -> (Element?, Element?) where PossibleMirror.Element == Element
}
```

### Complexity

All of these methods have to walk the entirety of both sources until
corresponding non-matches are found, so they work in O(_n_) operations, where
_n_ is the length of the shorter source.

### Comparison with other languages

**C++:** The `<algorithm>` library defines the `mismatch` function, which has
similar semantics to `firstDelta`.

(To-do: add other languages.)