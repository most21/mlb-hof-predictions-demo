open Owl;;

(* Given a list of player IDs, construct a feature matrix for the KNN predictions. *)
val build_feature_matrix : string list -> Dense.Matrix.S

(* 
    Generate predictions for each example in the provided feature matrix based on the k nearest neighbors. 
    Output is a vector of probabilities for each player.
*)
val predict : Dense.Matrix.S -> k:int -> Dense.Ndarray.S

(* Given a player ID, get the HOF prediction score for that player *)
val get_player_prediction : string -> float