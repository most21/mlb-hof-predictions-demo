open Owl

(* Alias the module instead of just opening it to preserve readability *)
module Mt = Owl.Dense.Matrix.S


type knn_model = {index: string array; matrix: Mt.mat; labels: float array; col_names: string array; pitcher: bool; mean: Mt.mat; std: Mt.mat}
type player = {id: string; data: float array; label: float}
type prediction = {label: string; neighbors: Dataframe.t}

(* Return a KNN model for either pitchers (true) or hitters (false) as specified via argument. *)
val build_knn_model : pitcher:bool -> limit:int -> knn_model

(* 
    This does the heavy lifting of constructing a KNN model for pitchers or hitters. 
    It gets called by build_knn_model.
    The first argument is a function to get either pitcher or hitter data, depending on which model is being built.
*)
val build_knn_model_internal : (unit -> Dataframe.t option) -> int -> bool -> knn_model

(* 
    Given a player, find the KNN data for that player. 
    This is used both to construct the KNN model data matrix and to get output data for the nearest neighbors.
*)
val find_player_data : string -> knn_model -> player

(* 
    Given an array of integer indices into the knn data matrix representing the nearest neighbors,
        create a nicely formatted output dataframe with the original data.
 *)
val build_neighbor_df : int array -> knn_model -> Dataframe.t

(* 
    Generate predictions for each example in the provided feature matrix based on the k nearest neighbors. 
    Output is a vector of probabilities for each player.
*)
val predict : knn_model -> string -> k:int -> prediction (*float array*)

(* Given a player ID, get the HOF prediction score for that player *)
(* val get_player_prediction : string -> float *)