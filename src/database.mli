open Owl

(* ################### Main query helper functions ################### *)

(* Execute a non-query SQL command, like dropping/creating tables. *)
val exec_non_query_sql : ?indicator:string -> Sqlite3.db -> string -> unit

(* 
    Execute a query SQL command (i.e. one that returns data) 
    Args: db connection, string with sql query
    Returns an Owl dataframe option. Note that each value in the dataframe will be a string.
*)
val exec_query_sql : Sqlite3.db -> string -> Dataframe.t option


(* ################### Database maintenance functions ################### *)

(* Given a list of table names, drop each one in the table. This is a preparatory step for re-loading the schema. *)
val drop_db_tables : Sqlite3.db -> string list -> unit

(* Create the schema for the database. *)
val create_schema : unit -> unit

(* Helper method to insert rows of data (stored as a dataframe) into the specified table. *)
val insert_rows : string -> Dataframe.t -> Sqlite3.db -> unit

(* Wrapper method to insert rows of data into a specified table. Calls insert_rows. *)
val insert_rows_wrapper : string -> Dataframe.t -> unit

(* Populate the database. Assume the schema exists. *)
val populate_database : unit -> unit


(* ################### General utility functions ################### *)

(* Given a playerID, Determine if this player is a pitcher (true) or a batter (false). *)
val is_pitcher : string -> (bool, string) result

(* Get all players- just playerIDs and full names, no other data *)
val get_all_players : unit -> Dataframe.t

(* Helper function to get all of a single batter's offensive data. Called by get_player_stats *)
val get_batter_data : string -> Dataframe.t

(* Helper function to get all of a single pitcher's pitching data. Called by get_player_stats *)
val get_pitcher_data : string -> Dataframe.t

(* Given a player ID, return that player's full data, either batting or pitching data. *)
val get_player_stats : string -> Dataframe.t

(* 
    Given a player's name, find the ID of that player in the database.
    Returns a tuple of (# players with that same name, string representation of dataframe containing all options)
*)
val find_player_id : string -> (int * string, string) result

(* Check if the given player is a member of the Hall of Fame. *)
val is_hofer : string -> (bool, string) result

(* Given a dataframe of player data, label each player as a HOFer or not (Y/N) *)
val label_hofers : Dataframe.t -> Dataframe.t


(* ################### JAWS-specific functions ################### *)

(* Specialized version that gets only the data necessary to compute peak WAR for JAWS *)
val get_player_stats_jaws : string -> Dataframe.t option

(* Helper method for getting a batter's data *)
val get_batter_data_for_jaws : string -> Dataframe.t option

(* Helper method for getting a pitcher's data *)
val get_pitcher_data_for_jaws : string -> Dataframe.t option

(* Helper method to get JAWS neighbors for a player. *)
val get_neighbors_jaws : string -> bool -> int -> Dataframe.t option

(* Given a playerID, find the 10 most similar players (either batters or hitters) by WAR. *)
val query_nearby_players_jaws : string -> int -> Dataframe.t option



(* ################### KNN-specific functions ################### *)

(* Get KNN data for a single batter. *)
val get_single_batter_data_for_knn : string -> Dataframe.t option

(* Get KNN data for a single pitcher. *)
val get_single_pitcher_data_for_knn : string -> Dataframe.t option

(* 
    Get KNN data for some number of batters. 
    Limit the size of the data by passing in an integer number of players to use, or -1 to use all. 
*)
val get_batter_data_for_knn : ?num_players:int -> unit -> Dataframe.t option

(* 
    Get KNN data for some number of pitchers. 
    Limit the size of the data by passing in an integer number of players to use, or -1 to use all. 
*)
val get_pitcher_data_for_knn : ?num_players:int -> unit -> Dataframe.t option
