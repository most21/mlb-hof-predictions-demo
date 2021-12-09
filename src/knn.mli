open Owl

(* Alias the module instead of just opening it to preserve readability *)
module Mt = Owl.Dense.Matrix.S


type knn_model = {index: string array; matrix: Mt.mat; labels: float array; col_names: string array; pitcher: bool}
type prediction = {label: string; neighbors: Dataframe.t}

(* Builds a KNN model for either pitchers (true) or hitters (false) as specified via argument. *)
val build_knn_model : pitcher:bool -> knn_model

(* 
    Generate predictions for each example in the provided feature matrix based on the k nearest neighbors. 
    Output is a vector of probabilities for each player.
*)
val predict : knn_model -> string -> k:int -> prediction (*float array*)

(* Given a player ID, get the HOF prediction score for that player *)
(* val get_player_prediction : string -> float *)