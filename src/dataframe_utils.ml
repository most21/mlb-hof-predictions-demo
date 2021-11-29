open Owl


let read_data_file (file: string) : Dataframe.t = 
    Dataframe.of_csv file ~sep:','


let print_dataframe (df: Dataframe.t) = 
    Owl_pretty.pp_dataframe Format.std_formatter df

let dataframe_to_string (df: Dataframe.t) = 
    Owl_pretty.dataframe_to_string df

let unpack_dataframe (df_opt: Dataframe.t option) : Dataframe.t = 
    match df_opt with
    | Some df -> df
    | None -> failwith "Could not unpack dataframe option type. This should never happen."