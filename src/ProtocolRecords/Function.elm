module ProtocolRecords.Function (..) where


append' aAppendable f g x =
    aAppendable.append (f x) (g x)


appendable' aAppendable =
    { append = append' aAppendable }



-- monoid


empty' aMonoid _ =
    aMonoid.empty


monoid' aMonoid =
    let
        appendable = appendable' aMonoid.appendable
    in
        { appendable = appendable
        , empty = empty' aMonoid
        , append = appendable.append
        }



-- mappable


map : (a -> b) -> (c -> a) -> c -> b
map =
    (<<)


mappable =
    { map = map
    }



-- applicative


wrap : a -> b -> a
wrap =
    always


apply : (a -> b -> c) -> (a -> b) -> a -> c
apply f g x =
    f x (g x)


applicative =
    { mappable = mappable
    , wrap = wrap
    , apply = apply
    }



-- chainable, aka monad


andThen : (a -> b) -> (b -> a -> c) -> a -> c
andThen f k =
    \r -> k (f r) r


flatten : (a -> a -> b) -> a -> b
flatten x =
    x `andThen` identity


chainable =
    { applicative = applicative
    , andThen = andThen
    , flatten = flatten
    }
