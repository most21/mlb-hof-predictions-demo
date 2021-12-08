open Core
open Owl

(* Alias the module instead of just opening it to preserve readability *)
module Mt = Owl.Dense.Matrix.S

let num_batter_cols = 19
(* let pitcher_cols = 27 *)

type knn_model = {id_list: string array; matrix: Mt.mat; labels: float array}

let build_batter_knn_model ?(matrix_file="") () : knn_model = 
  match Database.get_batter_data_for_knn () with
  | Some df -> 
    begin
      let labeled_batter_data = Database.label_hofers df in
      let batter_index = Dataframe.get_col_by_name labeled_batter_data "playerID" |> Dataframe.unpack_string_series in
      let batter_labels = 
        Dataframe.get_col_by_name labeled_batter_data "HOF" 
        |> Dataframe.unpack_string_series 
        |> Array.map ~f:(fun h -> if String.(=) h "Y" then 1.0 else 0.0)
      in
      match matrix_file with
      | "" -> 
        begin
            Dataframe.remove_col labeled_batter_data (Dataframe.head_to_id labeled_batter_data "playerID");
            Dataframe.remove_col labeled_batter_data (Dataframe.head_to_id labeled_batter_data "HOF");
            
            let float_data = labeled_batter_data |> Dataframe.to_rows |> Array.map ~f:(fun arr -> Array.map arr ~f:(fun x -> Float.of_string @@ Dataframe.elt_to_str x)) in 
            let flattened = float_data |> Array.to_list |> Array.concat in
            let data_matrix = Mt.of_array flattened (Array.length batter_index) num_batter_cols in
            Mt.save ~out:"data/batter_knn_matrix.b" data_matrix;
            {id_list=batter_index; matrix=data_matrix; labels=batter_labels}
          end
      | f -> {id_list=batter_index; matrix=(Mt.load f); labels=batter_labels}      
    end
  | None -> failwith "Couldn't get batter data for KNN"




      (* Dataframe_utils.print_dataframe labeled_batter_data;
      print_string "\n";
      print_string @@ Int.to_string (Array.length batter_index);
      print_string "\n";
      print_string @@ Int.to_string (Array.length batter_labels);
      print_string "\n";
      Mt.print data_matrix ~max_row:10 ~max_col:10;
      print_string "\n"; *)



(*
let build_feature_matrix' () : unit = 
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

*)


(* print_string (List.to_string (List.take batter_id_list 20000) ~f:Fn.id);
   print_string "\n";
   print_string (List.to_string (List.take pitcher_id_list 20000) ~f:Fn.id);
   print_string "\n"; *)