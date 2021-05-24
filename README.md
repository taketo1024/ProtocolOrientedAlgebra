# SwiftyMath

The aim of this project is to understand Mathematics by realizing abstract concepts as codes. Mathematical axioms correspond to `protocol`s, and objects satisfying some axioms correspond to `struct`s.

# Submodules

* [SwiftyHomology](https://github.com/taketo1024/SwiftyMath-homology)
* [SwiftyTopology](https://github.com/taketo1024/SwiftyMath-topology)
* [SwiftyKnots](https://github.com/taketo1024/SwiftyMath-knots)

# Getting Started

```shell
$ swift run --repl
```

```
1> import SwmCore
2> let a: Matrix3x3<Int> = [1,2,3,4,5,6,7,8,9]
3> a.determinant
```

# Samples
* [Numbers](Playgrounds/Numbers.playground/Contents.swift)
* [Matrix](Playgrounds/Matrix.playground/Contents.swift)

## License
**Swifty Math** is released under [MIT license](LICENSE).
