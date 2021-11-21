open Core
open Sqlite3
open Owl

(* Some useful globals *)
let db_schema_file = "data/schema.sql"
let db_file = "mlb-hof.db"
let all_table_names = ["People"; "TeamsFranchises"; "AwardsPlayers"; "AwardsSharePlayers"; "Batting"; "BattingPost"; "HallOfFame"; "Pitching"; "PitchingPost"; "SeriesPost"; "Teams"; "Advanced"]


let exec_non_query_sql (db: Sqlite3.db) (sql: string) = 
  let result = Sqlite3.exec_no_headers db sql ~cb:(fun _ -> ()) 
  in 
  match result with
  | Rc.OK -> print_string ".\n"
  | _ -> print_string @@ "Error: " ^ (Rc.to_string result) ^ "    " ^ sql ^ "\n"


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

(* let insert_rows (table: string) (data: Dataframe.t) = 
  let sql = "INSERT INTO " ^ " VALUES ("
  in 
  Owl.iter_row data ~f:(Array.t )

let populate_database (table_names: string list) = 
  let& db = Sqlite3.db_open db_file 
  in
  List.iter table_names ~f:(fun table -> Dataframe_utils.read_data_file (table ^ ".csv"))


   *)