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

Integer pins compare equal to string pins with the same decimal spelling:
`.int(1) == .str("1")`, but `.int(1) != .str("01")`. Hashing follows that
equality. The pin case still controls traversal: `tree["1"]` reads a dictionary
key and `tree[1]` reads an array index. A string pin's `intValue` parses its text;
`isInt` checks its case. Creating a pin from a CodingKey uses its `intValue`
when present.

``Enigma/allPaths`` returns paths of all descendants, including empty containers,
excluding the root. Traversal is depth first with sorted dictionary keys and
ascending array indices. Scalars and empty roots have no descendant paths.

## Merge policy

Dictionary pairs merge recursively. New keys are inserted without a conflict.

- `merging(_:policy:)` uses `.replace` to take incoming values or `.skip` to keep
  existing values. Both select arrays as whole values by default.
- `merging(_:skipEqual:)` keeps equal values when `skipEqual` is true and throws
  `EncodingError.invalidValue` for other conflicts. When false, even equal
  conflicts throw.
- A custom `resolve` closure receives the path, existing value and incoming value
  for each non-dictionary pair, including whole arrays. New keys bypass it.

Set a policy's `arrayAction` independently of its `replaceValue` flag:

```swift
var policy: Enigma.MergePolicy = .replace
policy.arrayAction = .zip
let original: Enigma = [["name": "Ada", "score": 1], 2]
let patch: Enigma = [["score": 3], 4, 5]
let merged = original.merging(patch, policy: policy)
// [["name": "Ada", "score": 3], 4, 5]
```

`.zip` recursively merges matching indices and keeps the longer array's tail.
`.append` puts incoming elements after existing ones; `.prepend` puts them
before. `.selectOriginal` and `.selectOther` choose one whole array. These
actions apply only to array pairs; mixed types use `replaceValue`.

The throwing mutating merges commit only after the complete operation succeeds.
A thrown resolver leaves the original tree intact. Resolver visitation order for
dictionary keys is unspecified; avoid depending on side-effect order.

## Complexity

Path lookup takes expected O(d) time for a path of depth d, assuming expected
constant-time dictionary lookup. Mutation also walks the path in O(d) expected
time. Copy-on-write may copy a modified array or dictionary when its storage is
shared, so worst-case mutation work depends on the sizes of collections along
the path. `allPaths` visits every node and sorts keys within each dictionary;
its output storage is proportional to the total number of emitted pins.

Recursive merge visits overlapping dictionary structure and, for `.zip`, matching
array indices. Append and prepend copy the added elements. Resolver work is
additional, and copy-on-write may copy modified collections.
The nonthrowing `merge(_:policy:)` reuses uniquely owned dictionary storage;
shared dictionaries are copied when modified, preserving independent tree copies.
