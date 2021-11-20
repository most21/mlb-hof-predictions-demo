(* open Owl *)


(* Given a list of table names, drop each one in the table. This is a preparatory step for re-loading the schema. *)
val drop_db_tables : Sqlite3.db -> string list -> unit

(* Create the schema for the database. *)
val create_schema : unit -> unit

(* Execute a non-query SQL command, like dropping/creating tables. *)
val exec_non_query_sql : Sqlite3.db -> string -> unit

(* Insert rows of data (stored as a dataframe) into the specified table.
val insert_rows : string -> Dataframe.t -> unit

(* Insert the csv data files into the database. Takes a list of filenames to read and assumes the schema exists. *)
val populate_database : string list -> unit

(* Given a player ID, return that player's data. TODO: return type *)
val get_player_data : string -> Dataframe.t *)