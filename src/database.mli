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

val insert_rows_wrapper : string -> Dataframe.t -> unit

val is_pitcher : string -> (bool, string) result

(* Get all players *)
val get_all_players : unit -> Dataframe.t

(* val get_all_batters : unit -> Dataframe.t

val get_all_pitchers : unit -> Dataframe.t *)

(* Given a player ID, return that player's data. *)
val get_player_stats : string -> Dataframe.t

(* Specialized version that gets only the data necessary to compute peak WAR for JAWS *)
val get_player_stats_jaws : string -> Dataframe.t option

val get_batter_data_for_jaws : string -> Dataframe.t option

val get_pitcher_data_for_jaws : string -> Dataframe.t option


val get_single_batter_data_for_knn : string -> Dataframe.t option

val get_single_pitcher_data_for_knn : string -> Dataframe.t option

(* Limit the size of the data by passing in an integer number of players to use, or -1 to use all. *)
val get_batter_data_for_knn : ?num_players:int -> unit -> Dataframe.t option
val get_pitcher_data_for_knn : ?num_players:int -> unit -> Dataframe.t option

(* 
    Given a player's name, return the ID of that player. 
    If there are multiple players with the same name, return a dataframe of options. 
*)
val find_player_id : string -> (int * string, string) result


(* Given a playerID, find the 10 most similar players (either batters or hitters) by WAR. *)
val query_nearby_players_jaws : string -> int -> Dataframe.t option

(* Check if the given player is a hall of famer. *)
val is_hofer : string -> (bool, string) result

(* Given a dataframe of player data, label each player as a HOFer or not (Y/N) *)
val label_hofers : Dataframe.t -> Dataframe.t