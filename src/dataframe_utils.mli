open Owl;;

val read_data_file : string -> Dataframe.t

val write_data_file : Dataframe.t -> unit

val print_dataframe : Dataframe.t -> unit

val add_float_column : Dataframe.t -> float list -> Dataframe.t

val add_string_column : Dataframe.t -> string list -> Dataframe.t
