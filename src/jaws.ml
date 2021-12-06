open Owl
open Core

type player_peak = {id: string; war: float}


let compute_peak_statistics (data: Dataframe.t)  (peak_size: int) : player_peak =
  let player_id = Dataframe.get_by_name data 0 "playerID" |> Dataframe.elt_to_str in
  let wars = Dataframe_utils.get_column data "WAR162" |> List.map ~f:(Float.of_string) in
  let peak_war = 
    List.sort wars ~compare:Float.compare 
    |> List.rev 
    |> (fun l -> List.take l peak_size)
    |> (fun l -> List.sum (module Float) l ~f:Fn.id) 
  in {id=player_id; war=peak_war}


let compute_peak_all_players (peak_size: int) : Dataframe.t = 
  let output_df = Dataframe.make [|"playerID"; "peakWar"|] in
  let players = Database.get_all_players () in 
  let iter_func (row: Dataframe.elt array) : unit = 
    let player_id = Array.get row 0 |> Dataframe.elt_to_str in 
    let data = Database.get_player_stats_jaws player_id 
    in
    match data with
    | Some df -> 
      begin
        let peak = compute_peak_statistics df peak_size in
        let new_row = match peak with {id = i; war = w} -> Dataframe.([| pack_string i; pack_float w|]) in
        Dataframe.append_row output_df new_row; print_string @@ player_id ^ "\n"
      end
    | None -> print_string @@ "FAILED on " ^ player_id ^ ". Skipping.\n"
  in 
  Dataframe.iter_row iter_func players; 
  output_df

let add_peak_data_to_db (data: Dataframe.t) : unit = 
  Database.insert_rows_wrapper "Peak" data


let get_nearby_players (player_id: string) (num_neighbors: int) : Dataframe.t =
  let neighbors = Database.query_nearby_players_jaws player_id num_neighbors
  in
  match neighbors with
  | Some df -> Database.label_hofers df
  | None -> failwith "Could not find JAWS neighbors"

let predict (neighbors: Dataframe.t) : Dataframe.t * string =
  let num_neighbors = Dataframe.row_num neighbors in
  let hof_col = Dataframe.get_col_by_name neighbors "HOF" |> Dataframe.unpack_string_series in
  let num_hofers = Array.sum (module Int) hof_col ~f:(fun h -> if String.(=) h "Y" then 1 else 0) in
  let s = Format.sprintf "%d/%d nearest neighbors by peak WAR were inducted into the Hall of Fame.\n\n" num_hofers num_neighbors in
  (neighbors, s)