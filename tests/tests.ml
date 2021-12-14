open OUnit2
open Core
open Owl
(* open Sqlite3 *)

open Hof

(* ################### Database tests ################### *)

let test_is_pitcher _ = 
  assert_equal (Ok false) @@ Database.is_pitcher "troutmi01";
  assert_equal (Ok true) @@ Database.is_pitcher "scherma01";
  assert_equal (Ok false) @@ Database.is_pitcher "cobbty01";
  assert_equal (Ok true) @@ Database.is_pitcher "koufasa01";
  assert_equal (Error "Could not determine if player is pitcher.\n") @@ Database.is_pitcher "fakeID01"

let test_find_player_id _ = 
  assert_equal (Ok (1, "troutmi01")) @@ Database.find_player_id "Mike Trout";
  assert_equal (Ok (1, "scherma01")) @@ Database.find_player_id "Max Scherzer";
  assert_equal (Error "Could not find player with name 'Joe Shmoe'\n") @@ Database.find_player_id "Joe Shmoe"

let test_is_hofer _ =
  assert_equal (Ok false) @@ Database.is_hofer "troutmi01";
  assert_equal (Ok false) @@ Database.is_hofer "scherma01";
  assert_equal (Ok true) @@ Database.is_hofer "cobbty01";
  assert_equal (Ok true) @@ Database.is_hofer "koufasa01"


let database_tests = 
  "Database Tests"
  >: test_list
    [
      "Is Pitcher?" >:: test_is_pitcher;
      "Find player ID" >:: test_find_player_id;
      "Is HOFer?" >:: test_is_hofer;
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
  test "troutmi01" 20.41 2;
  assert_raises (Failure "ERROR - JAWS:test_compute_peak_statistics") (fun () -> test "fakeID01" 6.12 10)

let test_get_nearby_players _ = 
  let test player_id num_neighbors = 
    let df = Jaws.get_nearby_players player_id num_neighbors in
    assert_equal num_neighbors (Dataframe.row_num df)
  in
  test "scherma01" 10;
  test "troutmi01" 5;
  assert_raises (Failure "Could not find JAWS neighbors") (fun () -> Jaws.get_nearby_players "fakeID01" 10)

let test_predict_jaws _ = 
  let test player_id num_neighbors = 
    let df = Jaws.get_nearby_players player_id num_neighbors in
    let (neighbor_df, _) = Jaws.predict df in
    assert_equal num_neighbors (Dataframe.row_num neighbor_df)
  in
  test "scherma01" 10;
  test "troutmi01" 5

let jaws_tests = 
  "JAWS Tests" 
  >: test_list
    [
      "Compute peak stats" >:: test_compute_peak_statistics;
      "Get nearby players" >:: test_get_nearby_players;
      "Predict (JAWS)" >:: test_predict_jaws;
    ]

(* ################### KNN tests ################### *)
module Mt = Owl.Dense.Matrix.S

let test_build_knn_model _ = 
  let test (model: Knn.knn_model) true_limit true_cols true_is_pitcher = 
    assert_equal true_limit (Array.length model.index);
    assert_equal true_limit (Array.length model.labels);
    assert_equal true_cols (Array.length model.col_names);
    assert_equal true_is_pitcher model.pitcher;
    assert_equal (true_limit, true_cols) (Mt.shape model.matrix);
  in
  let pitcher_model = Knn.build_knn_model ~pitcher:true ~limit:100 in test pitcher_model 100 9 true;
  let batter_model = Knn.build_knn_model ~pitcher:false ~limit:100 in test batter_model 100 8 false

let test_find_player_data _ = 
  let pitcher_model = Knn.build_knn_model ~pitcher:true ~limit:100 in
  let batter_model = Knn.build_knn_model ~pitcher:false ~limit:100 in
  let test (result: Knn.player) true_player_id true_label true_num_cols = 
    assert_equal true_player_id result.id;
    assert_equal true_label result.label;
    assert_equal true_num_cols (Array.length result.data);
  in 
  test (Knn.find_player_data "scherma01" pitcher_model) "scherma01" 0.0 9; 
  test (Knn.find_player_data "ruthba01" batter_model) "ruthba01" 1.0 8

let test_build_neighbor_df _ = 
  let pitcher_model = Knn.build_knn_model ~pitcher:true ~limit:100 in
  let batter_model = Knn.build_knn_model ~pitcher:false ~limit:100 in
  let test (result: Dataframe.t) true_num_results true_num_cols = 
    assert_equal (true_num_results, true_num_cols) (Dataframe.shape result);
  in
  test (Knn.build_neighbor_df [|0; 1; 2|] pitcher_model) 3 (9 + 2);
  test (Knn.build_neighbor_df [|0; 1; 2; 5; 8; 12; 55|] batter_model) 7 (8 + 2)

let test_predict_knn _ = 
  let pitcher_model = Knn.build_knn_model ~pitcher:true ~limit:100 in
  let batter_model = Knn.build_knn_model ~pitcher:false ~limit:100 in
  let test (result: Knn.prediction) true_num_neighbors true_num_cols = 
    assert_equal true ((String.(=) "Y" result.label) || (String.(=) "N" result.label));
    assert_equal (true_num_neighbors, true_num_cols) (Dataframe.shape result.neighbors)
  in
  test (Knn.predict pitcher_model "scherma01" ~k:5) 5 (9 + 2);
  test (Knn.predict batter_model "troutmi01" ~k:12) 12 (8 + 2)


let knn_tests = 
  "KNN Tests" 
  >: test_list
    [
      "Build KNN model" >:: test_build_knn_model;
      "Get 1 player's KNN data" >:: test_find_player_data;
      "Build output neighbor dataframe" >:: test_build_neighbor_df;
      "Predict (KNN)" >:: test_predict_knn;
    ]

(* ################### Run entire series of tests ################### *)
let series = "MLB HOF Tests" >::: [
    database_tests;
    jaws_tests;
    knn_tests;
  ]

let () = run_test_tt_main series