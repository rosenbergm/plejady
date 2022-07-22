open Caqti_request.Infix
open Caqti_type.Std

type t =
  { id : string
  ; gid : string
  ; email : string
  ; is_admin : bool
  }
[@@deriving yojson]

type create_student_params =
  { gid : string
  ; email : string
  ; is_admin : bool
  }
[@@deriving yojson]

let student =
  let encode { id; gid; email; is_admin } = Ok (id, gid, email, is_admin) in
  let decode (id, gid, email, is_admin) = Ok { id; gid; email; is_admin } in
  let rep = Caqti_type.(tup4 string string string bool) in
  custom ~encode ~decode rep
;;

let get_students_query = (unit ->* student) @@ "SELECT * FROM students"

let get_students (module Db : Caqti_lwt.CONNECTION) =
  Db.collect_list get_students_query ()
;;

let get_student_by_gid_query =
  (string ->? student) @@ "SELECT * FROM students WHERE gid = ?"
;;

let get_student_by_gid (module Db : Caqti_lwt.CONNECTION) =
  Db.find_opt get_student_by_gid_query
;;

let create_student_query =
  (tup2 string string ->! string)
  @@ "INSERT INTO students (gid, email) VALUES (?, ?) RETURNING id"
;;

let create_student (module Db : Caqti_lwt.CONNECTION) = Db.find create_student_query
