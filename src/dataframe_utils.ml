open Owl


let read_data_file (file: string) : Dataframe.t = 
    Dataframe.of_csv file ~sep:','


let print_dataframe (df: Dataframe.t) = 
    Owl_pretty.pp_dataframe Format.std_formatter df