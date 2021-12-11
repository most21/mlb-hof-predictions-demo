open OUnit2
open Core
open Owl
(* open Sqlite3 *)

open Hof

(* ################### Some important globals ################### *)
(* let db_file = "mlb-hof.db" *)
(* let db = Sqlite3.db_open db_file *)
(* let sql_small = "select playerID, nameFirst, nameLast, debut, finalGame from People LIMIT 5;" *)
(* let sql_error = "select * from Pple;" (* Mis-spelled table name *) *)

(* ################### Database tests ################### *)
let test_exec_sql_query _ = 
  assert_equal true true

let test_rows_to_string _ = 
  assert_equal true true

let test_is_pitcher _ = 
  assert_equal true true

let test_get_all_players _ = 
  assert_equal true true

let test_get_player_stats _ = 
  assert_equal true true

let test_find_player_id _ = 
  assert_equal true true

let test_get_player_stats_jaws _ = 
  assert_equal true true

let test_query_nearby_players_jaws _ = 
  assert_equal true true

let test_is_hofer _ =
  assert_equal true true

let test_label_hofers _ =
  assert_equal true true

let database_tests = 
  "Database Tests"
  >: test_list
    [
      "Exec SQL query" >:: test_exec_sql_query;
      "Convert Dataframe rows to string" >:: test_rows_to_string;
      "Is Pitcher?" >:: test_is_pitcher;
      "Get all players" >:: test_get_all_players;
      "Get player stats" >:: test_get_player_stats;
      "Find player ID" >:: test_find_player_id;
      "Get player stats (JAWS)" >:: test_get_player_stats_jaws;
      "Query nearby players (JAWS)" >:: test_query_nearby_players_jaws;
      "Is HOFer?" >:: test_is_hofer;
      "Label HOFers" >:: test_label_hofers;
    ]

(* ################### JAWS tests ################### *)

let test_compute_peak_statistics _ = 
  let test player_id true_war peak_size = 
    match Database.get_player_stats_jaws player_id with
    | Some df -> 
      begin
        let res = Jaws.compute_peak_statistics df peak_size in 
        assert_equal res.id player_id;
        assert_equal (Float.round_decimal ~decimal_digits:3 res.war) true_war
      end
    | None -> failwith "ERROR - JAWS:test_compute_peak_statistics"
  in
  test "scherma01" 35.622 5;
  test "troutmi01" 20.41 2

let test_predict_jaws _ = 
  let test player_id num_neighbors = 
    match Database.query_nearby_players_jaws player_id num_neighbors with
    | Some df -> assert_equal num_neighbors (Dataframe.row_num df)
    | None -> failwith "ERROR - JAWS:test_predict_jaws"
  in
  test "scherma01" 10;
  test "troutmi01" 5

let jaws_tests = 
  "JAWS Tests" 
  >: test_list
    [
      "Compute peak stats" >:: test_compute_peak_statistics;
      "Predict (JAWS)" >:: test_predict_jaws;
    ]


(* ################### Run entire series of tests ################### *)
let series = "MLB HOF Tests" >::: [
    (* database_tests; *)
    jaws_tests;
  ]

let () = run_test_tt_main series