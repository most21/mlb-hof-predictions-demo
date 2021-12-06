open Core

(* TODO: Add Player option eventually *)
type input = MenuOption of int | Player of string | Invalid of string

let main_menu_choices = [1; 2; 3; 4; 42]
let db_admin_menu_choices = [1; 2; 3; 4]


let perform_player_disambiguation_selection (choice: int) (quit: bool ref) = 
  print_string @@ "You selected " ^ (Int.to_string choice) ^ "\n";
  quit := true


let print_player_input_prompt () = 
  print_string "Enter the name of a current/former MLB player (FirstName LastName): "

let print_main_menu () = 
  print_string "+======================================================================+\n";
  print_string "+ Welcome to the MLB Hall of Fame prediction engine. Select an option: +\n";
  print_string "+     1 - View player data                                             +\n";
  print_string "+     2 - Predict HOF candidacy for a player with JAWS                 +\n";
  print_string "+     3 - Predict HOF candidacy for a player with KNN                  +\n";
  print_string "+     4 - Quit                                                         +\n";
  print_string "+     42 - Super Secret Admin Panel                                    +\n";
  print_string "+======================================================================+\n";
  ()

let print_db_menu () = 
  print_string "+======================================================================+\n";
  print_string "+ Super Secret Database Admin Panel. Select an option:                 +\n";
  print_string "+     1 - Create database schema                                       +\n";
  print_string "+     2 - Populate database                                            +\n";
  print_string "+     3 - Quit                                                         +\n";
  print_string "+     4 - Test current task                                            +\n";
  print_string "+======================================================================+\n";
  ()

let print_prompt (prefix: string) = 
  match prefix with
  | "main" -> print_string "> "
  | _ -> print_string @@ prefix ^ " > "

let parse_menu_choice (s: string) (choices: int list): input = 
  let is_int (str: string) : bool = 
    try Int.of_string str |> fun _ -> true with
    | Failure _ -> false
  in
  let contains (l: 'a list) (value: 'a) : bool = List.exists l ~f:(fun c -> value = c)
  in
  match s with
  | _ when is_int s -> 
    begin
      match Int.of_string s with
      | x when contains choices x -> MenuOption x
      | _ -> Invalid s
    end
  | _ -> Invalid s

(* TODO: Delete "You selected..." once I know the CLI definitely works *)
let menu_choice_loop ?(prompt_prefix="main") (print_menu: unit -> unit) (choices: int list) (selection_handler: int -> bool ref -> unit) = 
  print_menu ();
  let quit = ref false in
  while not !quit do
    print_prompt prompt_prefix;
    Out_channel.flush stdout;
    match In_channel.input_line In_channel.stdin with
    | Some s -> 
      begin
        match parse_menu_choice s choices with
        | MenuOption opt -> print_string @@ "You selected " ^ (Int.to_string opt) ^ "\n"; selection_handler opt quit
        | Player _ -> failwith "Not possible for parse_menu_choice to return a Player type"
        | Invalid y -> print_string @@ "Invalid input: " ^ y ^ "\n";
      end
    | None -> print_string "\nNo input detected. Exiting menu.\n"; quit := true
  done

let parse_player_input (s: string) = 
  let clean = String.for_all s ~f:(fun ch -> Char.is_alpha ch || Char.is_whitespace ch)
  in
  match clean with
  | true -> Player s
  | false -> Invalid s

(* TODO: need to finish disambiguation *)
let get_player_input (quit: bool ref) (do_next: string -> unit) = 
  print_player_input_prompt ();
  Out_channel.flush stdout;
  match In_channel.input_line In_channel.stdin with
  | Some s -> 
    begin
      match parse_player_input s with
      | Player p -> 
        begin
          print_string @@ "You selected " ^ p ^ "\n"; (* TODO: delete this later *)
          match Database.find_player_id p with
          | Error s -> print_string s
          | Ok (matches, player_id) when matches = 1 -> do_next player_id
          | Ok (matches, df_str) when matches > 1 -> 
            begin
              print_string (Format.sprintf "Found multiple players with name '%s'. Enter row number to select a player.\n" p); 
              print_string @@ df_str ^ "\n";
              let choices = List.range ~start:`inclusive ~stop:`exclusive 0 matches
              in menu_choice_loop ~prompt_prefix:"row #" (fun () -> ()) choices perform_player_disambiguation_selection
            end
          | _ -> failwith "Unreachable case"
        end
      | Invalid y -> print_string @@ "Invalid input: " ^ y ^ "\n";
      | MenuOption _ -> failwith "Not possible for parse_player_input to return a MenuOption type"
    end
  | None -> print_string "\nNo input detected. Exiting menu.\n"; quit := true


let perform_db_menu_selection (choice: int) (quit: bool ref) = 
  match choice with
  | 1 -> Database.create_schema ()
  | 2 -> Database.populate_database ()
  | 3 -> print_string "Leaving the database admin and returning to the main menu....\n"; quit := true
  | 4 -> 
    begin
      let df = Jaws.get_nearby_players "scherma01" 10 in 
      let _, s = Jaws.predict df in
      Dataframe_utils.print_dataframe df; print_string @@ "\n" ^ s ^ "\n"
    end
  (* Jaws.add_peak_data_to_db (Jaws.compute_peak_all_players 7) *)
  (* let _ = Jaws.compute_peak_all_players 7 in () *)
    (* begin
      (* print_string "reached here first"; *)
      (* Jaws.compute_peak_all_players 7; *)
      let data = Database.get_batter_data_for_jaws "martijd02" 
      in
      match data with 
      | Some df -> let r = Jaws.compute_peak_statistics df 5 in print_string @@ (r.id) ^ "    " ^ (Float.to_string r.war) ^ "\n"
      | None -> failwith "Test failed"
    end *)
  | _ -> failwith "Unreachable case: user menu choice should already be validated at this point."

let perform_main_menu_selection (choice: int) (quit: bool ref) = 
  match choice with
  | 1 -> get_player_input quit (fun id -> Dataframe_utils.print_dataframe @@ Database.get_player_stats id)
  | 2 -> get_player_input quit (fun id -> match Jaws.predict (Jaws.get_nearby_players id 10) with (n_df, s) -> Dataframe_utils.print_dataframe n_df; print_string s)
  | 3 -> failwith "TODO: HOF predictions with KNN"
  | 4 -> print_string "Goodbye.\n"; quit := true
  | 42 -> menu_choice_loop print_db_menu db_admin_menu_choices perform_db_menu_selection ~prompt_prefix:"db"
  | _ -> failwith "Unreachable case: user menu choice should already be validated at this point."



let run_main_menu_loop () = 
  menu_choice_loop print_main_menu main_menu_choices perform_main_menu_selection





(* let parse_player_selection (_: string) = 
  failwith "Unimplemented"

let player_disambiguation (_: string) =
  failwith "Unimplemented" *)