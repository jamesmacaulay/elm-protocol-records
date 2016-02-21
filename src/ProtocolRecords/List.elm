module ProtocolRecords.List (..) where


append : List a -> List a -> List a
append =
    List.append


appendable =
    { append = append }



-- monoid


empty : List a
empty =
    []


monoid =
    { appendable = appendable
    , append = append
    , empty = empty
    }



-- mappable


map : (a -> b) -> List a -> List b
map =
    List.map


mappable =
    { map = map
    }



-- applicative


wrap : a -> List a
wrap x =
    [ x ]


apply : List (a -> b) -> List a -> List b
apply fs xs =
    let
        applyToXs f =
            List.map ((<|) f) xs
    in
        List.map applyToXs fs |> List.concat


applicative =
    { mappable = mappable
    , wrap = wrap
    , apply = apply
    }



-- chainable, aka monad


flatten : List (List a) -> List a
flatten =
    List.concat


andThen : List a -> (a -> List b) -> List b
andThen xs f =
    List.map f xs |> flatten


chainable =
    { applicative = applicative
    , wrap = wrap
    , andThen = andThen
    , flatten = flatten
    }



-- foldable


foldr : (a -> b -> b) -> b -> List a -> b
foldr =
    List.foldr


foldable =
    { foldr = foldr }



-- invertable, aka traversable


mapInvert' someApplicative f =
    let
        cons_f x ys =
            someApplicative.apply (someApplicative.mappable.map (::) (f x)) ys
    in
        foldr cons_f (someApplicative.wrap [])


invert' someApplicative =
    mapInvert' someApplicative identity


invertable' someApplicative =
    { mappable = mappable
    , foldable = foldable
    , mapInvert = mapInvert' someApplicative
    , invert = invert' someApplicative
    }
