open Owl;;


(* Read a csv file into a dataframe *)
val read_data_file : string -> Dataframe.t

(* Write a dataframe to a csv file. *)
(* val write_data_file : Dataframe.t -> unit *)

(* Pretty print an Owl dataframe *)
val print_dataframe : Dataframe.t -> unit

(* Convert a dataframe to a printable string *)
val dataframe_to_string : Dataframe.t -> string

(* Add a float column to a dataframe *)
(* val add_float_column : Dataframe.t -> float list -> Dataframe.t *)

(* Add a string column to a dataframe *)
(* val add_string_column : Dataframe.t -> string list -> Dataframe.t *)

(* Given a dataframe option, unpack it to extract the underlying dataframe. *)
val unpack_dataframe : Dataframe.t option -> Dataframe.t

(* Given a dataframe and a column name, return a list of strings with all values in the column *)
val get_column : Dataframe.t -> string -> string list

(* Fold over a dataframe. Surprised this doesn't exist in the Owl library, but here we are. *)
val fold : Dataframe.t -> init:'accum -> f:('accum -> Dataframe.elt array -> 'accum) -> 'accum