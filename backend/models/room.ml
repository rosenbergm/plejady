open Caqti_request.Infix
open Caqti_type.Std

type t =
  { id : string
  ; name : string
  ; capacity : int
  }
[@@deriving yojson]

type create_room_params =
  { name : string
  ; capacity : int
  }
[@@deriving yojson]

let room =
  let encode { id; name; capacity } = Ok (id, name, capacity) in
  let decode (id, name, capacity) = Ok { id; name; capacity } in
  let rep = Caqti_type.(tup3 string string int) in
  custom ~encode ~decode rep
;;

let get_rooms_query = (unit ->* room) @@ "SELECT * FROM rooms"
let get_rooms (module Db : Caqti_lwt.CONNECTION) = Db.collect_list get_rooms_query ()

let create_room_query =
  (tup2 string int ->! string)
  @@ "INSERT INTO rooms (name, capacity) VALUES (?, ?) RETURNING id"
;;

let create_room (module Db : Caqti_lwt.CONNECTION) = Db.find create_room_query
