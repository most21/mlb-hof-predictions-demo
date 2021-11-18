open Owl

(* Given a dataframe of a player's career data, compute their peak statistics. *)
val compute_peak_statistics : Dataframe.t -> peak_size:int -> Dataframe.t

(* For a query player, get players with similar peak stats. *)
val get_nearby_players : string -> Dataframe.t

(* Given nearby players, compute fraction of those players that are in the HOF as an estimate of HOF probability. *)
val predict : Dataframe.t -> float