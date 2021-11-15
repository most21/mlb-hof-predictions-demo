
(* Set the schema for the database. TODO: take DB connection as argument? *)
val create_schema : unit -> unit

(* Insert a row of data into the specified table. TODO: more input...? *)
val insert_row : string -> _

(* Given a player ID, return that player's data. TODO: return type *)
val get_player_data : string -> _