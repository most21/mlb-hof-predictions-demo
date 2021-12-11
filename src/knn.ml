open Core
open Owl

(* Alias the module instead of just opening it to preserve readability *)
module Mt = Dense.Matrix.S


let num_batter_cols = 8
let num_pitcher_cols = 9


type knn_model = {index: string array; matrix: Mt.mat; labels: float array; col_names: string array; pitcher: bool; mean: Mt.mat; std: Mt.mat}
type player = {id: string; data: float array; label: float}
type prediction = {label: string; neighbors: Dataframe.t}


let build_knn_model_internal (get_data: unit -> Dataframe.t option) (num_cols: int) (pitcher: bool) : knn_model = 
  match get_data () with
  | Some df -> 
    begin
      let labeled_data = Database.label_hofers df in
      let index = Dataframe.get_col_by_name labeled_data "playerID" |> Dataframe.unpack_string_series in
      let labels = 
        Dataframe.get_col_by_name labeled_data "HOF" 
        |> Dataframe.unpack_string_series 
        |> Array.map ~f:(fun h -> if String.(=) h "Y" then 1.0 else 0.0)
      in
      Dataframe.remove_col labeled_data (Dataframe.head_to_id labeled_data "playerID");
      Dataframe.remove_col labeled_data (Dataframe.head_to_id labeled_data "HOF");

      let convert_to_float_array arr = 
        Array.map arr ~f:(fun x -> Float.of_string @@ Dataframe.elt_to_str x)
      in
      let float_data = labeled_data |> Dataframe.to_rows |> Array.map ~f:convert_to_float_array in 
      let flattened = float_data |> Array.to_list |> Array.concat in
      let data_matrix = Mt.of_array flattened (Array.length index) num_cols in
      let mean = Mt.mean data_matrix ~axis:0 in
      let std = Mt.std data_matrix ~axis:0 in
      let centered_data = Mt.div (Mt.sub data_matrix mean) std in
      {index=index; matrix=centered_data; labels=labels; col_names=(Dataframe.get_heads labeled_data); pitcher=pitcher; mean=mean; std=std}
    end
  | None -> failwith "Couldn't get data for KNN"


let build_knn_model ~pitcher:(pitcher: bool) : knn_model = 
  match pitcher with
  | true -> build_knn_model_internal (Database.get_pitcher_data_for_knn) num_pitcher_cols pitcher
  | false -> build_knn_model_internal (Database.get_batter_data_for_knn) num_batter_cols pitcher


(* Helper function to essentially broadcast a 1-D array into a matrix. *)
let init_matrix_from_row (row: float array) (num_rows: int) : Mt.mat = 
  let matrix = Mt.zeros num_rows (Array.length row) in
  let row_idx = List.range 0 num_rows in
  List.iter row_idx ~f:(fun i -> Array.iteri row ~f:(fun j x -> Mt.set matrix i j x));
  matrix

(* Helper function to extract a single row of a matrix and return it as an OCaml array.
let get_row (matrix: Mt.mat) (row: int) : float array = 
  Mt.get_slice [[row]] matrix |> Mt.to_array *)

(* Helper function to get the number of rows in a matrix. *)
let num_rows (matrix: Mt.mat) : int = 
  match Mt.shape matrix with (dim1, _) -> dim1


(* Given a player ID, get the data needed for the KNN algorithm. *)
let find_player_data (player_id: string) (model: knn_model) : player = 
  let data_to_model (df_opt: Dataframe.t option) = 
    match df_opt with
    | Some df -> 
      begin
        let df = Database.label_hofers df in
        let label = 
          if String.(=) (Dataframe.get_by_name df 0 "HOF" |> Dataframe.elt_to_str) "Y" then 
            1.0 
          else 
            0.0 
        in
        let data = 
          Dataframe.remove_col df (Dataframe.head_to_id df "playerID"); 
          Dataframe.remove_col df (Dataframe.head_to_id df "HOF"); (* Remove playerID and HOF from row before casting to float *)
          let row = Dataframe.get_row df 0 in
          row |> Array.map ~f:(fun x -> Float.of_string @@ Dataframe.elt_to_str x)
        in
        {id=player_id; data=data; label=label}
      end
    | None -> failwith @@ "Could not get KNN data for " ^ player_id ^ "\n"
  in
  match model.pitcher with
  | true -> data_to_model (Database.get_single_pitcher_data_for_knn player_id)
  | false -> data_to_model (Database.get_single_batter_data_for_knn player_id)

(* Construct an output dataframe with the data of the k nearest neighbors. *)
let build_neighbor_df (neighbors: int array) (model: knn_model): Dataframe.t = 
  let df = Dataframe.make model.col_names in
  let add_row_to_df idx = 
    let player_data = find_player_data (Array.get model.index idx) model in
    player_data.data
    |> Array.map ~f:Dataframe.pack_float
    |> fun r -> Dataframe.append_row df r
  in
  Array.iter neighbors ~f:add_row_to_df; 
  let player_id_series = 
    neighbors
    |> Array.map ~f:(fun idx -> Array.get model.index idx)
    |> Dataframe.pack_string_series
  in
  let label_series = 
    neighbors
    |> Array.map ~f:(fun idx -> if Float.(=) (Array.get model.labels idx) 1.0 then "Y" else "N")
    |> Dataframe.pack_string_series
  in
  Dataframe.insert_col df 0 "playerID" player_id_series;
  Dataframe.append_col df label_series "HOF";
  df

(* Classify a player using the KNN algorithm. *)
let predict (model: knn_model) (player_id: string) ~k:(k: int) : prediction = 
  let target = find_player_data player_id model in
  let target_matrix = init_matrix_from_row (target.data) (num_rows model.matrix) in
  let target_centered = Mt.div (Mt.sub target_matrix model.mean) model.std in
  let diff = Mt.sub model.matrix target_centered in
  let dist = Mt.l2norm diff ~axis:1 in
  let nearest = (* TODO: need to chop off the first one if it's the same as the target, else keep *)
    Mt.bottom dist (k) (* Take the smallest k+1 distances *)
    (* |> (fun l -> Array.slice l 1 (Array.length l)) The lowest dist will be the row compared with itself. Need to skip that one *)
    |> Array.map ~f:(fun arr -> Array.get arr 0) (* The bottom func returns pairs, but we only need the row indices, not cols (there's only 1 col anyway) *)
  in
  let nearest_labels = Array.map nearest ~f:(fun i -> Array.get model.labels i) in
  let score = Array.sum (module Float) nearest_labels ~f:Fn.id in
  let pred = if (Int.of_float score) > (k / 2) then "Y" else "N" in
  let neighbor_df = build_neighbor_df nearest model in
  {label=pred; neighbors=neighbor_df}


  (* print_string target.id;
  print_string "\n";
  print_string @@ Int.to_string target.idx;
  print_string "\n";
  print_string (target.data |> Array.to_list |> List.to_string ~f:Float.to_string);
  print_string "\n";
  print_string @@ Float.to_string target.label;
  print_string "\n"; *)