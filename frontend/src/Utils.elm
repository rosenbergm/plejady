module Utils exposing (..)


ifThenElse : Bool -> a -> a -> a
ifThenElse condition ifTrue ifFalse =
    if condition then
        ifTrue

    else
        ifFalse