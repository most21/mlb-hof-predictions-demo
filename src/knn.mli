open Owl;;

(* Generate predictions for each example in the provided feature matrix based on the k nearest neighbors. *)
val predict : int -> Dense.Matrix.S -> Dense.Ndarray.S