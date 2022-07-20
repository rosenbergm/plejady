open Caqti_request.Infix
open Caqti_type.Std

type t =
  { id : string
  ; block_start : string
  ; block_end : string
  }
[@@deriving yojson]

type create_timeblock_params =
  { block_start : string
  ; block_end : string
  }
[@@deriving yojson]

let validate_time input =
  Str.string_match (Str.regexp "^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$") input 0
;;

let timeblock =
  let encode { id; block_start; block_end } =
    if validate_time block_start && validate_time block_end
    then Ok (id, block_start, block_end)
    else Error "Invalid time format"
  in
  let decode (id, block_start, block_end) = Ok { id; block_start; block_end } in
  let rep = Caqti_type.(tup3 string string string) in
  custom ~encode ~decode rep
;;

let get_timeblocks_query = (unit ->* timeblock) @@ "SELECT * FROM timeblocks"

let get_timeblocks (module Db : Caqti_lwt.CONNECTION) =
  Db.collect_list get_timeblocks_query ()
;;

let create_timeblock_query =
  (tup2 string string ->! string)
  @@ "INSERT INTO timeblocks (block_start, block_end) VALUES (?, ?) RETURNING id"
;;

let create_timeblock (module Db : Caqti_lwt.CONNECTION) = Db.find create_timeblock_query
