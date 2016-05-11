# ProtocolRecords

**Do not use this library in your application.** It remains available here for educational purposes only.

**This library is an experiment** in using Elm's extensible records as explicit type class instances. Currently the library implements a few commonly used type classes from Haskell for a few of Elm's core types. For background on this approach, see [_Scrap your type classes_](http://www.haskellforall.com/2012/05/scrap-your-type-classes.html) and various related discussions on the Elm Discuss group ([example](https://groups.google.com/d/msg/elm-discuss/b5KfZfnMl3s/enoFUcG5b8EJ)).

**For better or worse, it turns out this approach is fundamentally flawed.** Elm's type system does not allow many of Haskell's typeclasses to be implemented this way. For example, Applicative is defined as a protocol in this library but using it in a generic way will result in an error from the Elm compiler as the type inference engine cannot reconcile needing multiple concrete types for the same `apply` function:

```
> applicativeOnePlusTwo {wrap, apply} = wrap (+) `apply` (wrap 1) `apply` (wrap 2)
-- TYPE MISMATCH --------------------------------------------- repl-temp-000.elm

The argument to function `wrap` is causing a mismatch.

3│                                                         wrap 1)
                                                                ^
Function `wrap` is expecting the argument to be:

    number -> number -> number

But it is:

    number
```

## Terminology

* A **protocol** is a set of operations which must follow a certain set of laws, and which can be implemented for multiple types. Corresponds to a type class in Haskell.
* A **protocol implementation** is an extensible record that implements a protocol for a single type.
* Some of Haskell's type classes have different names in this library:
  - Semigroup is called **appendable** here
    - mappend is just **append**
  - Monoid's mempty is just **empty**
  - Functor is **mappable**
    - fmap is just **map**
  - Applicative's pure and (<\*>) are **wrap** and **apply**
  - Monad is **chainable**
    - (>>=) is **andThen**
    - return is **wrap**
    - join is **flatten**
  - Traversable is **invertable**
    - sequenceA is **invert**
    - traverse is **mapInvert**

## Usage

Here's what List's `mappable` protocol implementation looks like:

```elm
{ map = List.map }
```

Here's Maybe's implementation of the same protocol:

```elm
{ map = Maybe.map }
```

If you want a function that can map over both Lists and Maybes, you can write such a function like this:

```elm
incrementAll' mappableImpl = mappableImpl.map ((+) 1)
```

We put one single-quote on the end of the function name to indicate that it takes one protocol implementation record as its first argument. This is what it looks like to use it:

```elm
import ProtocolRecords.List as ListImpls
import ProtocolRecords.Maybe as MaybeImpls

Just 1 |> incrementAll' MaybeImpls.mappable
-- Just 2
[1, 2] |> incrementAll' ListImpls.mappable
-- [2,3]
```

Now, you may be wondering why on earth you'd want to go to this much trouble instead of just using `List.map` or `Maybe.map` on their own. The answer is: usually it _isn't_ worth it! But sometimes you might have a lot of logic that you really want to be able to work with multiple types, and the only alternative would be to duplicate a lot of code. In these cases, ProtocolRecords _might_ be worth it.

## Parent Protocols

Some protocols require that in order for a type to have an implementation of said protocol, _another_ protocol already be implemented for that type. This forms a dependency or parent/child relationship between protocols, the equivalent of superclass/subclass inheritance in Haskell.

In this library, implementations of parent protocols are found in the child protocol's implementation record alongside the rest of the implemented values. For example, here is the inferred type of Maybe's `applicative` implementation:

```elm
{ apply : Maybe.Maybe (a -> b) -> Maybe.Maybe a -> Maybe.Maybe b
, mappable : { map : (c -> d) -> Maybe.Maybe c -> Maybe.Maybe d }
, wrap : e -> Maybe.Maybe e
}
```

If a function takes an `applicative` implementation as an argument, it can access the parent `mappable` implementation in this way if it needs to.

## Parameterized Implementations

The types that implement protocols are often _parameterized_ by some other type. For example, `Maybe` is a type constructor that takes the type of its contained value as a type parameter. For Maybe's implementation of `mappable`, we don't need to know anything about Maybe's type parameter; the `map` function is polymorphic over all types.

Sometimes, however, an implementation of a protocol only makes sense if the type's parameter itself has an implementation of some protocol. In this library, we handle this situation by providing a parameterized implementation.

For example, Maybe's `appendable` implementation requires _another_ appendable implementation for the type contained in the Maybe. This is because `append`-ing Maybe values together relies on `append`-ing their contents when they are present. Here's what that looks like when you use it:

```elm
append = (MaybeImpls.appendable' ListImpls.appendable).append
Just [1,2,3] `append` Nothing `append` Just [4,5]
-- Just [1,2,3,4,5]
```

Note the single-quote suffix on `MaybeImpls.appendable'`, indicating that it takes another protocol implementation as its first argument.

Here's another example using the `invertable` protocol:

```elm
invertListOfMaybes = (ListImpls.invertable' MaybeImpls.applicative).invert
invertListOfMaybes [Just 1, Just 2]
-- Just [1,2]
```
