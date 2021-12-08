open Core
open Owl

(* Alias the module instead of just opening it to preserve readability *)
module Mt = Owl.Dense.Matrix.S

let num_batter_cols = 19
(* let pitcher_cols = 27 *)

(* type knn_model = {batter_id_list: string list; batter_matrix: Mt.mat; pitcher_id_list: string list; pitcher_matrix: Mt.mat} *)

(* let build_feature_matrix' () : unit (* Mt.mat *) =
   let players = Database.get_all_players () in 
   let fold_func accum row = 
    List.join [accum; row |> Array.map ~f:Dataframe.elt_to_str |> Array.to_list]
   in 
   let iter_func (row: Dataframe.elt array) : unit = 
    let player_id = Array.get row 0 |> Dataframe.elt_to_str in 
    let data = Database.get_player_stats_knn player_id 
    in
    match data with
    | Some df -> 
    | None -> print_string @@ "FAILED on " ^ player_id ^ ". Skipping.\n"
   in
   Dataframe.iter_row iter_func players;
   Dataframe_utils.fold players ~init:[] ~f:fold_func *)


let build_feature_matrix () : unit = 
  let batters = Database.get_all_batters () in 
  let pitchers = Database.get_all_pitchers () in
  let batter_id_list = 
    Dataframe_utils.fold batters ~init:[] ~f:(fun accum row -> (Dataframe.elt_to_str @@ Array.get row 0) :: accum) 
    |> List.rev 
  in
  let _ = 
    Dataframe_utils.fold pitchers ~init:[] ~f:(fun accum row -> (Dataframe.elt_to_str @@ Array.get row 0) :: accum) 
    |> List.rev 
  in
  let get_data player_id = 
    print_string player_id; print_string "\n";
    match Database.get_player_stats_knn player_id with
    | Some df -> 
      begin
        let row_string_array = Dataframe.get_row df 0 |> Array.map ~f:Dataframe.elt_to_str
        in
        (* TODO: instead of checking empty string, count how many floats there are *)
        match Array.count row_string_array ~f:(fun s -> String.(=) s "") with
        | 0 -> 
          begin
            let float_row = row_string_array |> Array.map ~f:Float.of_string 
            in 
            match Array.length float_row with
            | x when x = num_batter_cols -> float_row
            | _ -> [||]
          end
        | _ -> [||]
      end
    | None -> [||]
  in
  let all_batter_data = List.map (List.take batter_id_list 50) ~f:get_data |> Array.concat in 
  (* let _ = List.map pitcher_id_list ~f:map_func |> Array.concat in *)
  let num_batter_rows = (Array.length all_batter_data) / num_batter_cols in
  let batter_matrix = Mt.of_array all_batter_data num_batter_rows num_batter_cols in
  Mt.print batter_matrix;
  print_string "\n";
  Mt.save ~out:"data/batter_knn_matrix.b" batter_matrix
(* print_string @@ Int.to_string num_batter_rows;
   print_string "\n";
   print_string @@ Int.to_string (Array.length all_batter_data);
   print_string "\n" *)
(* print_string (all_batter_data |> Array.to_list |> fun l -> List.take l 10 |> List.to_string ~f:Float.to_string); *)
(* print_string "\n"; *)
(* print_string @@ Int.to_string (Array.length all_batter_data); *)




(* print_string (List.to_string (List.take batter_id_list 20000) ~f:Fn.id);
   print_string "\n";
   print_string (List.to_string (List.take pitcher_id_list 20000) ~f:Fn.id);
   print_string "\n"; *)