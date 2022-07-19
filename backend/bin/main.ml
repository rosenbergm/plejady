module Room = Models.Room

let json_response ?status x = x |> Yojson.Safe.to_string |> Dream.json ?status

let get_rooms request =
  match%lwt Dream.sql request Room.get_rooms with
  | Ok rooms -> `List (List.map Room.yojson_of_t rooms) |> json_response
  | Error _ -> Dream.empty `Not_Found
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
       ]
;;
