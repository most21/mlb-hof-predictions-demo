open Owl


(* Given a list of table names, drop each one in the table. This is a preparatory step for re-loading the schema. *)
val drop_db_tables : Sqlite3.db -> string list -> unit

(* Create the schema for the database. *)
val create_schema : unit -> unit

(* 
    Populate the database.
    Provide a list of DB table names to populate, each of which should have a corresponding .csv file. 
    Assume the schema exists.
*)
val populate_database : unit -> unit

(* Execute a non-query SQL command, like dropping/creating tables. *)
val exec_non_query_sql : ?indicator:string -> Sqlite3.db -> string -> unit

(* 
    Execute a query SQL command (i.e. one that returns data) 
    Args: db connection, string with sql query
    Returns an Owl dataframe option. Note that each value in the dataframe will be a string.
*)
val exec_query_sql : Sqlite3.db -> string -> Dataframe.t option


(* Insert rows of data (stored as a dataframe) into the specified table. *)
val insert_rows : string -> Dataframe.t -> Sqlite3.db -> unit



(* Get all players *)
val get_all_players : unit -> Dataframe.t

(* Given a player ID, return that player's data. TODO: return type *)
val get_player : string -> Dataframe.t