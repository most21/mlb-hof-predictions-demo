open Owl

type player_peak = {id: string; war: float}


(* Given a dataframe of a player's career data, compute their peak statistics. *)
val compute_peak_statistics : Dataframe.t -> int -> player_peak

(* Compute peak WAR totals for every player in the database, both hitters and pitchers. *)
val compute_peak_all_players : int -> Dataframe.t

(* Add peak war to the database for each player *)
val add_peak_data_to_db : Dataframe.t -> unit

(* For a query player, get players with similar peak stats. *)
val get_nearby_players : string -> int -> Dataframe.t

(* Given nearby players, compute fraction of those players that are in the HOF as an estimate of HOF probability. *)
val predict : Dataframe.t -> Dataframe.t * float

