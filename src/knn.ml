open Core
open Owl

(* Alias the module instead of just opening it to preserve readability *)
module Mt = Dense.Matrix.S

let num_batter_cols = 19
let num_pitcher_cols = 27


type knn_model = {index: string array; matrix: Mt.mat; labels: float array; col_names: string array}
type player = {id: string; idx: int; data: float array; label: float}
type prediction = {label: string; neighbors: Dataframe.t}


let build_knn_model_internal (get_data: unit -> Dataframe.t option) (num_cols: int) : knn_model = 
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
      {index=index; matrix=data_matrix; labels=labels; col_names=(Dataframe.get_heads labeled_data)}
    end
  | None -> failwith "Couldn't get data for KNN"


let build_knn_model ~pitcher:(pitcher: bool) : knn_model = 
  match pitcher with
  | true -> build_knn_model_internal (Database.get_pitcher_data_for_knn) num_pitcher_cols
  | false -> build_knn_model_internal (Database.get_batter_data_for_knn) num_batter_cols


(* Helper function to essentially broadcast a 1-D array into a matrix. *)
let init_matrix_from_row (row: float array) (num_rows: int) : Mt.mat = 
  let matrix = Mt.zeros num_rows (Array.length row) in
  let row_idx = List.range 0 num_rows in
  List.iter row_idx ~f:(fun i -> Array.iteri row ~f:(fun j x -> Mt.set matrix i j x));
  matrix

(* Helper function to extract a single row of a matrix and return it as an OCaml array. *)
let get_row (matrix: Mt.mat) (row: int) : float array = 
  Mt.get_slice [[row]] matrix |> Mt.to_array

(* Helper function to get the number of rows in a matrix. *)
let num_rows (matrix: Mt.mat) : int = 
  match Mt.shape matrix with (dim1, _) -> dim1


(* Given a player ID, find which row of the matrix has the corresponding data. *)
let find_player_data (player_id: string) (model: knn_model) : player = 
  let idx, _ = Array.findi_exn model.index ~f:(fun _ s -> String.(=) s player_id) in
  let data = get_row model.matrix idx in
  let label = Array.get model.labels idx in
  {id=player_id; idx=idx; data=data; label=label}

(* Construct an output dataframe with the data of the k nearest neighbors. *)
let build_neighbor_df (neighbors: int array) (model: knn_model): Dataframe.t = 
  let df = Dataframe.make model.col_names in
  let add_row_to_df idx = 
    get_row model.matrix idx
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
  let diff = Mt.sub model.matrix target_matrix in
  let dist = Mt.l2norm diff ~axis:1 in
  let nearest = 
    Mt.bottom dist (k + 1) (* Take the smallest k+1 distances *)
    |> (fun l -> Array.slice l 1 (Array.length l)) (* The lowest dist will be the row compared with itself. Need to skip that one *)
    |> Array.map ~f:(fun arr -> Array.get arr 0) (* The bottom func returns pairs, but we only need the row indices, not cols (there's only 1 col anyway) *)
  in
  let nearest_labels = Array.map nearest ~f:(fun i -> Array.get model.labels i) in
  let score = Array.sum (module Float) nearest_labels ~f:Fn.id in
  let pred = if (Int.of_float score) > (k / 2) then "Y" else "N" in
  let neighbor_df = build_neighbor_df nearest model in
  {label=pred; neighbors=neighbor_df}
  (* TODO: return list of player records? *)


  (* print_string target.id;
  print_string "\n";
  print_string @@ Int.to_string target.idx;
  print_string "\n";
  print_string (target.data |> Array.to_list |> List.to_string ~f:Float.to_string);
  print_string "\n";
  print_string @@ Float.to_string target.label;
  print_string "\n"; *)