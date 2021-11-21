open Owl;;

(* Read a csv file into a dataframe *)
val read_data_file : string -> Dataframe.t

(* Write a dataframe to a csv file. *)
(* val write_data_file : Dataframe.t -> unit *)

(* Pretty print an Owl dataframe *)
val print_dataframe : Dataframe.t -> unit

(* Add a float column to a dataframe *)
(* val add_float_column : Dataframe.t -> float list -> Dataframe.t *)

(* Add a string column to a dataframe *)
(* val add_string_column : Dataframe.t -> string list -> Dataframe.t *)
