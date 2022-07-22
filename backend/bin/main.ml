module Room = Models.Room
module Timeblock = Models.Timeblock
module Student = Models.Student
open Lwt
open Cohttp_lwt_unix

let flip f a b = f b a
let id a = a
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

let get_students request =
  match%lwt Dream.sql request Student.get_students with
  | Ok students -> `List (List.map Student.yojson_of_t students) |> json_response
  | Error _ -> Dream.empty `Not_Found
;;

type google_id_token =
  { hd : string
  ; email : string
  ; sub : string
  }
[@@deriving yojson] [@@yojson.allow_extra_fields]

let fetch_google_verification_tokens =
  Client.get (Uri.of_string "https://www.googleapis.com/oauth2/v3/certs")
  >>= fun (_, body) -> body |> Cohttp_lwt.Body.to_string >|= Jose.Jwks.of_string
;;

let check_claim claim expected (token : Jose.Jwt.t) =
  let open Yojson.Safe.Util in
  let open Yojson.Safe in
  if token.payload |> member claim |> equal expected then Some token else None
;;

let verify_google_id_token token =
  let ( >>= ) = Option.bind in
  let jwt_with_claims =
    try
      Result.to_option @@ Jose.Jwt.of_string token
      >>= check_claim
            "aud"
            (`String
              "788205997300-jguh4a1dv1c663l3ug9s4bok2skn83ej.apps.googleusercontent.com")
      >>= check_claim "iss" (`String "accounts.google.com")
      >>= check_claim "hd" (`String "student.alej.cz")
    with
    | _ -> None
  in
  match jwt_with_claims with
  | None -> Lwt.return None
  | Some jwt ->
    let%lwt jwks = fetch_google_verification_tokens in
    let validate jwk = Jose.Jwt.validate ~jwk in
    let is_token_valid =
      List.map (flip validate jwt) jwks.keys |> List.map Result.is_ok |> List.exists id
    in
    (if is_token_valid then Some (google_id_token_of_yojson jwt.payload) else None)
    |> Lwt.return
;;

type auth_doc = { token : string } [@@deriving yojson]

(* TODO: Possibly rewrite with binds and maps *)
let login =
  let login_base login_doc request =
    let open Lwt.Infix in
    match%lwt verify_google_id_token login_doc.token with
    | None -> Dream.empty `Forbidden
    | Some google_user ->
      (match%lwt
         Dream.sql request @@ flip Student.get_student_by_gid google_user.sub
         >|= Result.to_option
       with
       | None -> Dream.empty `Forbidden
       | Some student_request ->
         (match student_request with
          | None -> Dream.empty `Forbidden
          | Some student ->
            let%lwt () = Dream.invalidate_session request in
            let%lwt () = Dream.put_session "user" student.id request in
            Dream.empty `OK))
  in
  json_receiver auth_doc_of_yojson login_base
;;

let logout request =
  let%lwt () = Dream.invalidate_session request in
  Dream.empty `OK
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
       ; Dream.get "/students" get_students
       ; Dream.delete "/logout" logout
       ]
;;
