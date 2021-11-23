open Core
open Sqlite3
open Owl

(* Some useful globals *)
let db_schema_file = "data/schema.sql"
let db_file = "mlb-hof.db"
let all_table_names = ["People"; "TeamsFranchises"; "AwardsPlayers"; "AwardsSharePlayers"; "Batting"; "BattingPost"; "HallOfFame"; "Pitching"; "PitchingPost"; "SeriesPost"; "Teams"; "Advanced"]


let exec_non_query_sql ?(indicator=".") (db: Sqlite3.db) (sql: string) = 
  let result = Sqlite3.exec_no_headers db sql ~cb:(fun _ -> ()) 
  in 
  match result with
  | Rc.OK -> print_string indicator
  | _ -> print_string @@ "Error: " ^ (Rc.to_string result) ^ "    " ^ sql ^ "\n"

let exec_query_sql (db: Sqlite3.db) (sql: string): Dataframe.t option = 
  (* let df = Dataframe.make @@ Array.of_list cols in *)
  let df = ref None in
  let callback_func (db_row: string option array) (headers: string array) = 
    let pack_string_option item = 
      match item with 
      | Some s -> Dataframe.pack_string s 
      | None -> Dataframe.pack_string ""
    in 
    match !df with
    | None -> df := Some (Dataframe.make headers); Dataframe.append_row (Dataframe_utils.unpack_dataframe !df) (Array.map db_row ~f:pack_string_option)
    | _ -> Dataframe.append_row (Dataframe_utils.unpack_dataframe !df) (Array.map db_row ~f:pack_string_option)
  in 
  let result = Sqlite3.exec db sql ~cb:callback_func 
  in
  match result with
  | Rc.OK -> !df
  | _ -> None


let drop_db_tables (db: Sqlite3.db) (tables: string list)= 
  let sql_template = "DROP TABLE IF EXISTS "
  in List.iter tables ~f:(fun t -> exec_non_query_sql db (sql_template ^ t ^ ";"))

let create_schema () = 
  let& db = Sqlite3.db_open db_file 
  in
  db_schema_file
  |> In_channel.read_all
  |> String.split_on_chars ~on:[';']
  |> (fun l -> List.take l (List.length l - 1))
  |> (fun l ->
      drop_db_tables db all_table_names;
      print_string "Dropped all existing tables.\n";
      List.iter l ~f:(fun sql -> exec_non_query_sql db sql); 
      print_string "Loaded database schema!\n")


(* TODO: try replacing this with Dataframe.elt_to_str *)
let unpack_value_to_string (value: Dataframe.elt) : string = 
  match value with
  | Dataframe.Int x -> Int.to_string x
  | Dataframe.Float y -> Float.to_string y
  | Dataframe.String z -> z
  | _ -> failwith "Error: Value has unexpected type (not int, float, or string)"

let row_to_string (row: Dataframe.elt array) : string = 
  row
  |> Array.fold ~init:[] ~f:(fun accum elt -> (let s = unpack_value_to_string elt in accum @ [s]))
  |> List.map ~f:(fun s -> "\"" ^ s ^ "\"")
  |> String.concat ~sep:", "


let insert_rows (table: string) (data: Dataframe.t) (db: Sqlite3.db) = 
  let sql = Format.sprintf "INSERT INTO %s VALUES (%s);" table
  in Dataframe.iter_row (fun r -> exec_non_query_sql db (sql @@ row_to_string r) ~indicator:"") data


let populate_database () = 
  let& db = Sqlite3.db_open db_file 
  in 
  let iter_func t = 
    let df = Dataframe_utils.read_data_file ("data/clean/" ^ t ^ ".csv")
    in insert_rows t df db; print_string @@ "Populated " ^ t ^ " table\n";
  in
  List.iter all_table_names ~f:iter_func;
  print_string @@ "\nPopulated " ^ Int.to_string (List.length all_table_names) ^ " tables.\n"




let get_all_players () : Dataframe.t = 
  let& db = Sqlite3.db_open db_file in 
  let sql = "SELECT playerID, nameFirst, nameLast FROM People;" 
  in 
  match exec_query_sql db sql with
  | Some df -> df
  | None -> failwith "SQL query failed."

let get_player (player_id: string) : Dataframe.t = 
  let& db = Sqlite3.db_open db_file in 
  let sql = Format.sprintf "SELECT * FROM People WHERE playerID = '%s';" player_id 
  in
  match exec_query_sql db sql with
  | Some df -> df
  | None -> failwith "SQL query failed."