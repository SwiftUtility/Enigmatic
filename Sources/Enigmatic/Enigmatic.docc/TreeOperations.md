# Editing and merging trees

Navigate a value using string keys and integer array indices.

## Paths and mutations

```swift
var tree: Enigma = ["items": [[:], ["name": "first"]]]
tree["items", 1, "name"] = "second"
tree["items", 0] = nil
// ["items": [["name": "second"]]]
```

The empty path selects the root. Assigning a non-nil value replaces it, but
assigning nil does not remove the root. For child paths, nil means deletion and
`.null` is a stored null value. Deleting an array element shifts subsequent indices.

Setters create missing dictionary children and append at an array's count. They
do not replace an incompatible existing parent or fill gaps in an array. Invalid
paths are no-ops for writes and return nil for reads. The `or:` subscript evaluates
its fallback only when a read finds no value, not when the stored value is null
or during a simple assignment.

``Enigma/allPaths`` returns paths of all descendants, including empty containers,
excluding the root. Traversal is depth first with sorted dictionary keys and
ascending array indices. Scalars and empty roots have no descendant paths.

## Merge policy

Dictionary pairs merge recursively; every other pair, including arrays, is passed
to the resolver as a whole. New keys are inserted without calling the resolver.
The resolver receives the path, existing value and incoming value.

- `Enigma.replace` keeps the incoming value.
- `Enigma.skipEqual` keeps equal values and throws on differences.
- `Enigma.fail` rejects every conflict with `EncodingError.invalidValue`.

The mutating merge commits only after the complete operation succeeds. A thrown
resolver leaves the original tree intact. Resolver visitation order for dictionary
keys is unspecified; avoid depending on side-effect order.
