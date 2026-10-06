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

Non-nil setters create missing dictionary children, append at an array's count,
and replace a node with an empty dictionary or array when the next pin requires
that container. For example, writing `tree["profile", "name"]` replaces a
non-dictionary `profile` value with a dictionary before storing `name`.

An array index below zero or greater than the current count makes the entire
assignment a no-op. This remains atomic even when earlier pins would have
replaced containers. The index equal to `count` appends exactly one element;
gaps are never filled. Reads do not coerce containers and return nil when a pin
does not match the stored structure. Nil removes an existing child without
creating or replacing containers. The `or:` subscript evaluates its fallback
only when a read finds no value, not when the stored value is null or during a
simple assignment.

``Enigma/allPaths`` returns paths of all descendants, including empty containers,
excluding the root. Traversal is depth first with sorted dictionary keys and
ascending array indices. Scalars and empty roots have no descendant paths.

## Merge policy

Dictionary pairs merge recursively; every other pair, including arrays, is passed
to the resolver as a whole. New keys are inserted without calling the resolver.
The resolver receives the path, existing value and incoming value.

- `merging(_:replace:)` keeps the incoming value when `replace` is true and the
  existing value when it is false.
- `merging(_:skipEqual:)` keeps equal values when `skipEqual` is true and throws
  `EncodingError.invalidValue` for other conflicts.
- A custom `MergeStrategy` or `resolve` closure defines how other conflict pairs
  are selected. Newly encountered dictionary keys are copied without a callback.

The mutating merge commits only after the complete operation succeeds. A thrown
resolver leaves the original tree intact. Resolver visitation order for dictionary
keys is unspecified; avoid depending on side-effect order.

## Complexity

Path lookup takes expected O(d) time for a path of depth d, assuming expected
constant-time dictionary lookup. Mutation also walks the path in O(d) expected
time. Copy-on-write may copy a modified array or dictionary when its storage is
shared, so worst-case mutation work depends on the sizes of collections along
the path. `allPaths` visits every node and sorts keys within each dictionary;
its output storage is proportional to the total number of emitted pins.

Recursive merge visits overlapping dictionary structure and performs expected
constant-time dictionary operations per visited entry. Resolver work is
additional, and copy-on-write may copy modified dictionaries.
