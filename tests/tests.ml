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
let player_data = Database.get_player_stats_jaws "scherma01"


let test_compute_peak_statistics _ =   
  match player_data with
  | Some df -> 
    begin
      let res = Jaws.compute_peak_statistics df 5 in 
      assert_equal res.id "scherma01"; assert_equal (Float.round_decimal ~decimal_digits:3 res.war) 29.412
    end
  | None -> failwith "ERROR - JAWS:test_compute_peak_statistics"

let test_predict_jaws _ = 
  match Database.query_nearby_players_jaws "scherma01" 10 with
  | Some df -> assert_equal 10 (Dataframe.row_num df)
  | None -> failwith "ERROR - JAWS:test_predict_jaws"

let jaws_tests = 
  "JAWS Tests" 
  >: test_list
    [
      "Compute peak stats" >:: test_compute_peak_statistics;
      "Predict (JAWS)" >:: test_predict_jaws;
    ]


(* ################### Run entire series of tests ################### *)
let series = "MLB HOF Tests" >::: [
    database_tests;
    jaws_tests;
  ]

let () = run_test_tt_main series