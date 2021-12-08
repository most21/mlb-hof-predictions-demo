open Core
open Sqlite3
open Owl

(* Some useful globals *)
let db_schema_file = "data/schema.sql"
let db_file = "mlb-hof.db"
let all_table_names = ["People"; "TeamsFranchises"; "AwardsPlayers"; "AwardsSharePlayers"; "Batting"; "BattingPost"; "HallOfFame"; "Pitching"; "PitchingPost"; "SeriesPost"; "Teams"; "Advanced"]


let exec_non_query_sql ?(indicator=".") (db: Sqlite3.db) (sql: string) = 
  let result = Sqlite3.exec_no_headers db sql ~cb:(fun _ -> ()) 
  in 
  match result with
  | Rc.OK -> print_string indicator
  | _ -> print_string @@ "Error: " ^ (Rc.to_string result) ^ "    " ^ sql ^ "\n"

let exec_query_sql (db: Sqlite3.db) (sql: string): Dataframe.t option = 
  let df = ref None in
  let callback_func (db_row: string option array) (headers: string array) = 
    let pack_string_option item = 
      match item with 
      | Some s -> Dataframe.pack_string s 
      | None -> Dataframe.pack_string ""
    in 
    match !df with
    | None -> df := Some (Dataframe.make headers); Dataframe.append_row (Dataframe_utils.unpack_dataframe !df) (Array.map db_row ~f:pack_string_option)
    | _ -> Dataframe.append_row (Dataframe_utils.unpack_dataframe !df) (Array.map db_row ~f:pack_string_option)
  in 
  let result = Sqlite3.exec db sql ~cb:callback_func 
  in
  match result with
  | Rc.OK -> !df
  | _ -> None


let drop_db_tables (db: Sqlite3.db) (tables: string list)= 
  let sql_template = "DROP TABLE IF EXISTS "
  in List.iter tables ~f:(fun t -> exec_non_query_sql db (sql_template ^ t ^ ";"))

let create_schema () = 
  let& db = Sqlite3.db_open db_file 
  in
  db_schema_file
  |> In_channel.read_all
  |> String.split_on_chars ~on:[';']
  |> (fun l -> List.take l (List.length l - 1))
  |> (fun l ->
      drop_db_tables db all_table_names;
      print_string "Dropped all existing tables.\n";
      List.iter l ~f:(fun sql -> exec_non_query_sql db sql); 
      print_string "Loaded database schema!\n")


let row_to_string (row: Dataframe.elt array) : string = 
  row
  |> Array.fold ~init:[] ~f:(fun accum elt -> (let s = Dataframe.elt_to_str elt in accum @ [s]))
  |> List.map ~f:(fun s -> "\"" ^ s ^ "\"")
  |> String.concat ~sep:", "



let insert_rows (table: string) (data: Dataframe.t) (db: Sqlite3.db) : unit = 
  let sql = Format.sprintf "INSERT INTO %s VALUES (%s);" table
  in Dataframe.iter_row (fun r -> exec_non_query_sql db (sql @@ row_to_string r) ~indicator:"") data

let insert_rows_wrapper (table: string) (data: Dataframe.t) : unit = 
  let& db = Sqlite3.db_open db_file 
  in insert_rows table data db


let populate_database () = 
  let& db = Sqlite3.db_open db_file 
  in 
  let iter_func t = 
    let df = Dataframe_utils.read_data_file ("data/clean/" ^ t ^ ".csv")
    in insert_rows t df db; print_string @@ "Populated " ^ t ^ " table\n";
  in
  List.iter all_table_names ~f:iter_func;
  print_string @@ "\nPopulated " ^ Int.to_string (List.length all_table_names) ^ " tables.\n"


let is_pitcher (player_id: string) : (bool, string) result = 
  let& db = Sqlite3.db_open db_file in
  let sql = Format.sprintf "SELECT DISTINCT P.playerID, A.isPitcher FROM People as P, Advanced as A WHERE P.bbrefID = A.bbrefID AND P.playerID = '%s';" player_id 
  in
  match exec_query_sql db sql with
  | Some df -> 
    begin 
      let r = Dataframe.get_by_name df 0 "isPitcher" |> Dataframe.elt_to_str
      in
      match r with
      | "Y" -> Ok true
      | "N" -> Ok false
      | _ -> Error "Could not determine if player is pitcher."
    end
  | None -> Error ("SQL query failed: Could not determine if " ^ player_id ^ " is a pitcher.\n")


let get_all_players () : Dataframe.t = 
  let& db = Sqlite3.db_open db_file in 
  let sql = "SELECT playerID, nameFirst, nameLast FROM People;" 
  in 
  match exec_query_sql db sql with
  | Some df -> df
  | None -> failwith "SQL query failed. Could not get all players."

(* let get_all_batters () : Dataframe.t = 
  let& db = Sqlite3.db_open db_file in 
  let sql = "SELECT DISTINCT P.playerID, P.nameFirst, P.nameLast FROM People as P, Advanced as A WHERE P.bbrefID = A.bbrefID AND A.isPitcher = 'N';" 
  in 
  match exec_query_sql db sql with
  | Some df -> df
  | None -> failwith "SQL query failed. Could not get all batters."

let get_all_pitchers () : Dataframe.t = 
  let& db = Sqlite3.db_open db_file in 
  let sql = "SELECT DISTINCT P.playerID, P.nameFirst, P.nameLast FROM People as P, Advanced as A WHERE P.bbrefID = A.bbrefID AND A.isPitcher = 'Y';" 
  in 
  match exec_query_sql db sql with
  | Some df -> df
  | None -> failwith "SQL query failed. Could not get all pitchers." *)

let get_batter_data (player_id: string) : Dataframe.t =
  let& db = Sqlite3.db_open db_file in 
  let sql = Format.sprintf "SELECT 
    B.playerID, 
    B.yearID, 
    B.stint, 
    B.teamID, 
    B.lgID,
    B.G, 
    B.AB, 
    B.R, 
    B.H, 
    B._2B, 
    B._3B, 
    B.HR, 
    B.RBI, 
    B.SB, 
    B.CS, 
    B.BB, 
    B.SO, 
    B.IBB, 
    B.HBP, 
    B.SH, 
    B.SF, 
    B.GIDP, 
    A.wRC_plus, 
    A.bWAR162, 
    A.WAR162 
  FROM 
    People as P, 
    Advanced as A, 
    Batting as B 
  WHERE 
    P.playerID = '%s' AND 
    P.bbrefID = A.bbrefID AND 
    A.isPitcher = 'N' AND 
    P.playerID = B.playerID AND 
    B.yearID = A.yearID AND B.stint = A.stint;" player_id
  in 
  match exec_query_sql db sql with
  | Some df -> df
  | None -> failwith @@ "SQL query failed. Could not get batter data for " ^ player_id ^ "\n"

let get_pitcher_data (player_id: string) : Dataframe.t = 
  let& db = Sqlite3.db_open db_file in 
  let sql = Format.sprintf "SELECT 
    Pp.playerID, 
    P.yearID, 
    P.stint, 
    P.teamID, 
    P.lgID,
    P.W, 
    P.L, 
    P.G, 
    P.GS, 
    P.CG, 
    P.SHO, 
    P.SV, 
    P.IPouts, 
    P.H, 
    P.ER, 
    P.HR, 
    P.BB, 
    P.SO, 
    P.BAOpp, 
    P.ERA, 
    P.IBB, 
    P.WP, 
    P.HBP,
    P.BK,
    P.BFP,
    P.GF,
    P.R,
    P.SH,
    P.SF,
    P.GIDP,
    A.ERA_minus,
    A.xFIP_minus,
    A.pWAR162,  
    A.WAR162 
  FROM 
    People as Pp, 
    Advanced as A, 
    Pitching as P
  WHERE 
    Pp.playerID = '%s' AND 
    Pp.bbrefID = A.bbrefID AND 
    A.isPitcher = 'Y' AND 
    Pp.playerID = P.playerID AND 
    P.yearID = A.yearID AND P.stint = A.stint;" player_id
  in
  match exec_query_sql db sql with
  | Some df -> df
  | None -> failwith "SQL query failed. Could not get pitcher data"

let get_player_stats (player_id: string) : Dataframe.t = 
  match is_pitcher player_id with
  | Ok false -> get_batter_data player_id
  | Ok true -> get_pitcher_data player_id
  | Error s -> failwith s

let find_player_id (player_name: string) : (int * string, string) result = 
  let db = Sqlite3.db_open db_file in
  let sql = Format.sprintf 
      "SELECT DISTINCT
        P.playerID, 
        (P.nameFirst || ' ' || P.nameLast) as nameFull,
        P.debut,
        P.finalGame,
        A.isPitcher
      FROM 
        People as P, 
        Advanced as A
      WHERE
        P.bbrefID = A.bbrefID AND
        nameFull = '%s';" player_name
  in
  let res = exec_query_sql db sql in
  let _ = Sqlite3.db_close db in
  match res with
  | Some df -> 
    begin 
      match Dataframe.row_num df with
      | 0 -> Error (Format.sprintf "Could not find player with name '%s'" player_name)
      | 1 -> Ok (1, Dataframe.get_by_name df 0 "playerID" |> Dataframe.elt_to_str)
      | num_options -> Ok (num_options, Dataframe_utils.dataframe_to_string df)
    end
  | None -> failwith "SQL query failed."




let get_batter_data_for_jaws (player_id: string) : Dataframe.t option = 
  let& db = Sqlite3.db_open db_file in
  let sql = Format.sprintf "SELECT 
      B.playerID, 
      B.yearID, 
      B.stint, 
      GROUP_CONCAT(B.teamID) as teamID, 
      sum(A.WAR162) as WAR162
    FROM 
      People as P, 
      Batting as B, 
      Advanced as A 
    WHERE 
      P.playerID = '%s' AND 
      P.bbrefID = A.bbrefID AND 
      A.isPitcher = 'N' AND 
      P.playerID = B.playerID AND 
      B.yearID = A.yearID AND 
      B.stint = A.stint 
    GROUP BY B.yearID;" player_id
  in exec_query_sql db sql

let get_pitcher_data_for_jaws (player_id: string) : Dataframe.t option = 
  let& db = Sqlite3.db_open db_file in
  let sql = Format.sprintf "SELECT 
      Pp.playerID, 
      P.yearID, 
      P.stint, 
      GROUP_CONCAT(P.teamID) as teamID, 
      sum(A.WAR162) as WAR162
    FROM 
      People as Pp, 
      Advanced as A, 
      Pitching as P
    WHERE 
      Pp.playerID = '%s' AND 
      Pp.bbrefID = A.bbrefID AND 
      A.isPitcher = 'Y' AND 
      Pp.playerID = P.playerID AND 
      P.yearID = A.yearID AND P.stint = A.stint
    GROUP BY P.yearID;" player_id
  in exec_query_sql db sql


let get_player_stats_jaws (player_id: string) : Dataframe.t option = 
  match is_pitcher player_id with
  | Ok false -> get_batter_data_for_jaws player_id
  | Ok true -> get_pitcher_data_for_jaws player_id
  | Error _ -> None


let get_neighbors_jaws (player_id: string) (pitcher: bool) (num_neighbors: int): Dataframe.t option = 
  let& db = Sqlite3.db_open db_file in
  let is_pitch = if pitcher then "Y" else "N" in
  let sql = Format.sprintf "SELECT DISTINCT 
      Pp.playerID, 
      Pp.nameFirst, 
      Pp.nameLast, 
      P.peakWar, 
      R.peakWar as targetWar, 
      R.peakWar - P.peakWar as diff
    FROM 
      People as Pp,
      Peak as P, 
      Advanced as A,
      (SELECT peakWar FROM Peak WHERE playerID = '%s') as R
    WHERE 
      Pp.playerID = P.playerID AND
      Pp.bbrefID = A.bbrefID AND
      A.isPitcher = '%s' AND
      P.playerID <> '%s'
    ORDER BY ABS(diff) ASC LIMIT %d;" player_id is_pitch player_id num_neighbors
  in exec_query_sql db sql

let query_nearby_players_jaws (player_id: string) (num_neighbors: int): Dataframe.t option = 
  match is_pitcher player_id with
  | Ok false -> get_neighbors_jaws player_id false num_neighbors
  | Ok true -> get_neighbors_jaws player_id true num_neighbors
  | Error _ -> None

let is_hofer (player_id: string) : (bool, string) result = 
  let& db = Sqlite3.db_open db_file in
  let sql = Format.sprintf "SELECT '%s' IN (SELECT playerID FROM HallOfFame WHERE inducted = 'Y') as HOF" player_id
  in 
  match exec_query_sql db sql with
  | Some df -> 
    begin
      let r = Dataframe.get_by_name df 0 "HOF" |> Dataframe.elt_to_str
      in
      match r with
      | "1" -> Ok true
      | "0" -> Ok false
      | _ -> Error "Could not determine if player is in the Hall of Fame."
    end
  | None -> Error ("Could not find HOF status of " ^ player_id ^ "\n")

let label_hofers (players: Dataframe.t) : Dataframe.t = 
  let num_rows = Dataframe.row_num players in
  let series = Array.init num_rows ~f:(fun _ -> "N") |> Dataframe.pack_string_series in
  let iter_func (i: int) (row: Dataframe.elt array) = 
    let player_id = Array.get row (Dataframe.head_to_id players "playerID") |> Dataframe.elt_to_str in
    match is_hofer player_id with
    | Ok true -> Dataframe.set_by_name players i "HOF" (Dataframe.pack_string "Y")
    | _ -> ()
  in
  Dataframe.append_col players series "HOF"; 
  Dataframe.iteri_row iter_func players;
  players


let get_batter_data_for_knn () : Dataframe.t option = 
  let& db = Sqlite3.db_open db_file in
  let sql = "SELECT 
      P.playerID as playerID,
      sum(B.G) as G, 
      sum(B.AB) as AB, 
      sum(B.R) as R, 
      sum(B.H) as H, 
      sum(B._2B) as _2B, 
      sum(B._3B) as _3B, 
      sum(B.HR) as HR, 
      sum(B.RBI) as RBI, 
      sum(B.SB) as SB, 
      sum(B.CS) as CS, 
      sum(B.BB) as BB, 
      sum(B.SO) as SO, 
      sum(B.IBB) as IBB, 
      sum(B.HBP) as HBP, 
      sum(B.SH) as SH, 
      sum(B.SF) as SF, 
      sum(B.GIDP) as GIDP, 
      ROUND(sum(A.wRC_plus * B.G) / sum(B.G), 1) as wRC_plus, 
      sum(A.bWAR162) as bWAR162
    FROM 
      People as P, 
      Advanced as A, 
      Batting as B 
    WHERE 
      P.bbrefID = A.bbrefID AND 
      A.isPitcher = 'N' AND 
      P.playerID = B.playerID AND 
      B.yearID = A.yearID AND B.stint = A.stint
    GROUP BY P.playerID;"
  in exec_query_sql db sql

let get_pitcher_data_for_knn () : Dataframe.t option = 
  let& db = Sqlite3.db_open db_file in
  let sql = "SELECT 
      Pp.playerID as playerID,
      sum(P.W) as W, 
      sum(P.L) as L, 
      sum(P.G) as G, 
      sum(P.GS) as GS, 
      sum(P.CG) as CG, 
      sum(P.SHO) as SHO, 
      sum(P.SV) as SV, 
      sum(P.IPouts) as IPouts, 
      sum(P.H) as H, 
      sum(P.ER) as ER, 
      sum(P.HR) as HR, 
      sum(P.BB) as BB, 
      sum(P.SO) as SO, 
      ROUND(sum(P.BAOpp * P.IPouts) / sum(P.IPouts), 3) as BAOpp, 
      ROUND(sum(P.ERA * P.IPouts) / sum(P.IPouts), 2) as ERA, 
      sum(P.IBB) as IBB, 
      sum(P.WP) as WP, 
      sum(P.HBP) as HBP,
      sum(P.BK) as BK,
      sum(P.GF) as GF,
      sum(P.R) as R,
      sum(P.SH) as SH,
      sum(P.SF) as SF,
      sum(P.GIDP) as GIDP,
      ROUND(sum(A.ERA_minus * P.IPouts) / sum(P.IPouts), 1) as ERA_minus,
      ROUND(sum(A.xFIP_minus * P.IPouts) / sum(P.IPouts), 1) as xFIP_minus,
      sum(A.pWAR162) as pWAR162
    FROM 
      People as Pp, 
      Advanced as A, 
      Pitching as P
    WHERE 
      Pp.bbrefID = A.bbrefID AND 
      A.isPitcher = 'Y' AND 
      Pp.playerID = P.playerID AND 
      P.yearID = A.yearID AND P.stint = A.stint
    GROUP BY Pp.playerID;"
  in exec_query_sql db sql