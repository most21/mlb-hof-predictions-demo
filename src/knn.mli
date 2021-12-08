(* open Owl *)

(* Alias the module instead of just opening it to preserve readability *)
module Mt = Owl.Dense.Matrix.S

type knn_model = {id_list: string array; matrix: Mt.mat; labels: float array}

(* Construct a feature matrix for the KNN predictions containing all players in the database. *)
val build_batter_knn_model : ?matrix_file:string -> unit -> knn_model

(* 
    Generate predictions for each example in the provided feature matrix based on the k nearest neighbors. 
    Output is a vector of probabilities for each player.
*)
(* val predict : Dense.Matrix.S -> k:int -> Dense.Ndarray.S *)

(* Given a player ID, get the HOF prediction score for that player *)
(* val get_player_prediction : string -> float *)