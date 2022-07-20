module Room = Models.Room
module Timeblock = Models.Timeblock

let flip f a b = f b a
let json_response ?status x = x |> Yojson.Safe.to_string |> Dream.json ?status

type error_doc = { error : string } [@@deriving yojson]

let json_receiver json_parser handler request =
  let%lwt body = Dream.body request in
  let parse =
    try Some (body |> Yojson.Safe.from_string |> json_parser) with
    | _ -> None
  in
  match parse with
  | Some doc -> handler doc request
  | None ->
    { error = "Received invalid JSON input." }
    |> yojson_of_error_doc
    |> json_response ~status:`Bad_Request
;;

let get_rooms request =
  match%lwt Dream.sql request Room.get_rooms with
  | Ok rooms -> `List (List.map Room.yojson_of_t rooms) |> json_response
  | Error _ -> Dream.empty `Not_Found
;;

let create_room request =
  let create (spec : Room.create_room_params) request =
    let%lwt room_request =
      Dream.sql request @@ flip Room.create_room (spec.name, spec.capacity)
    in
    match room_request with
    | Ok room_id -> `String room_id |> json_response
    | Error _ -> Dream.empty `Not_Found
  in
  json_receiver Room.create_room_params_of_yojson create request
;;

let get_timeblocks request =
  match%lwt Dream.sql request Timeblock.get_timeblocks with
  | Ok timeblocks -> `List (List.map Timeblock.yojson_of_t timeblocks) |> json_response
  | Error _ -> Dream.empty `Not_Found
;;

let create_timeblock request =
  let create (spec : Timeblock.create_timeblock_params) request =
    let%lwt timeblock_request =
      Dream.sql request
      @@ flip Timeblock.create_timeblock (spec.block_start, spec.block_end)
    in
    match timeblock_request with
    | Ok timeblock_id -> `String timeblock_id |> json_response
    | Error _ -> Dream.empty `Bad_Request
  in
  json_receiver Timeblock.create_timeblock_params_of_yojson create request
;;

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.sql_pool "postgresql://plejady:plejady@localhost:5500/plejady"
  @@ Dream.sql_sessions
  @@ Dream.router
       [ Dream.get "/" (fun _ -> Dream.html "Good morning, world!")
       ; Dream.get "/echo/:word" (fun request -> Dream.html (Dream.param request "word"))
       ; Dream.get "/rooms" get_rooms
       ; Dream.post "/rooms" create_room
       ; Dream.get "/timeblocks" get_timeblocks
       ; Dream.post "/timeblocks" create_timeblock
       ]
;;
