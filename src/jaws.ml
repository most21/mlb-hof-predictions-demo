open Owl
open Core

let make_chunks (n: int) (l: 'a list): 'a list list =
  let rec aux l' accum = 
    match List.length l' with
    | x when x < n -> accum
    | _ ->
      match l' with
      | [] -> accum
      | _ :: rest -> aux rest ((List.take l' n) :: accum)
  in
  match n > List.length l with
  | true -> []
  | false -> aux l [] |> List.rev

(*
(* Find the max/argmax of a list of floats, return a tuple of (idx, val) *)
let argmax_exn (l: float list) : (int * float)= 
  let max_idx = ref (-1) in
  let fold_func idx accum x =
    match Float.(>) x accum with
    | false -> accum
    | true -> max_idx := idx; x 
  in
  match l with
  | [] -> failwith "Cannot take argmax of empty list"
  | _ -> !max_idx, List.foldi l ~init:(List.hd_exn l) ~f:fold_func *)


let compute_peak_statistics (data: Dataframe.t)  (peak_size: int) =
  let wars = Dataframe_utils.get_column data "WAR162" |> List.map ~f:(Float.of_string) in 
  let _ = Dataframe_utils.get_column data "yearID" |> List.map ~f:(Int.of_string) in
  let war_sums = make_chunks peak_size wars |> List.map ~f:(fun l -> List.sum (module Float) l ~f:Fn.id) in
  (List.to_string war_sums ~f:Float.to_string)


(*
let years = Dataframe.get_col_by_name data "yearID" |> Dataframe.unpack_int_series |> Array.to_list in
  let war_sums = make_chunks peak_size war |> List.map ~f:(fun l -> List.sum (module Float) l ~f:Fn.id) in
  let year_pairs = make_chunks peak_size years |> List.map ~f:(fun l -> (List.hd_exn l, l |> List.rev |> List.hd_exn )) in
  let peak_idx, peak_val = argmax_exn war_sums *)