open Owl

(* Set the schema for the database. TODO: take DB connection as argument? *)
val create_schema : unit -> unit

(* Insert rows of data (stored as a dataframe) into the specified table. *)
val insert_rows : string -> Dataframe.t -> unit

(* Insert the csv data files into the database. Takes a list of filenames to read and assumes the schema exists. *)
val populate_database : string list -> unit

(* Given a player ID, return that player's data. TODO: return type *)
val get_player_data : string -> Dataframe.t