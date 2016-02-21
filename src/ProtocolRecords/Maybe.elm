module ProtocolRecords.Maybe (..) where


append' appendableImpl mx my =
    case mx of
        Nothing ->
            my

        Just x ->
            case my of
                Nothing ->
                    mx

                Just y ->
                    Just (appendableImpl.append x y)


appendable' appendableImpl =
    { append = append' appendableImpl }



-- monoid


empty : Maybe a
empty =
    Nothing


monoid' appendableImpl =
    let
        appendable = appendable' appendableImpl
    in
        { appendable = appendable
        , empty = empty
        , append = appendable.append
        }



-- mappable


map : (a -> b) -> Maybe a -> Maybe b
map =
    Maybe.map


mappable =
    { map = map
    }



-- applicative


wrap : a -> Maybe a
wrap =
    Just


apply : Maybe (a -> b) -> Maybe a -> Maybe b
apply mf mx =
    case mf of
        Nothing ->
            Nothing

        Just f ->
            map f mx


applicative =
    { mappable = mappable
    , wrap = wrap
    , apply = apply
    }



-- chainable, aka monad


andThen : Maybe a -> (a -> Maybe b) -> Maybe b
andThen =
    Maybe.andThen


flatten : Maybe (Maybe a) -> Maybe a
flatten m =
    case m of
        Nothing ->
            Nothing

        Just mx ->
            mx


chainable =
    { applicative = applicative
    , andThen = andThen
    , flatten = flatten
    }



-- foldable


foldr : (a -> b -> b) -> b -> Maybe a -> b
foldr f b ma =
    case ma of
        Nothing ->
            b

        Just a ->
            f a b


foldable =
    { foldr = foldr }



-- traversable


traverse' someApplicative f mx =
    case mx of
        Nothing ->
            someApplicative.wrap Nothing

        Just x ->
            someApplicative.mappable.map Just (f x)


sequenceApplicative' someApplicative =
    traverse' someApplicative identity


traversable =
    { mappable = mappable
    , foldable = foldable
    , traverse' = traverse'
    , sequenceApplicative' = sequenceApplicative'
    }
