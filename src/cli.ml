open Core
(* open Owl *)

(* TODO: Add Player option eventually *)
type input = MenuOption of int |  Invalid of string (* | Player of string *)

let main_menu_choices = [1; 2; 3; 42]
let db_admin_menu_choices = [1; 2; 3]

let print_main_menu () = 
  print_string "+======================================================================+\n";
  print_string "+ Welcome to the MLB Hall of Fame prediction engine. Select an option: +\n";
  print_string "+     1 - View player data                                             +\n";
  print_string "+     2 - Predict HOF candidacy for a player                           +\n";
  print_string "+     3 - Quit                                                         +\n";
  print_string "+     42 - Super Secret Database Admin Panel                           +\n";
  print_string "+======================================================================+\n";
  ()

let print_db_menu () = 
  print_string "+======================================================================+\n";
  print_string "+ Super Secret Database Admin Panel. Select an option:                 +\n";
  print_string "+     1 - Create database schema                                       +\n";
  print_string "+     2 - Populate database                                            +\n";
  print_string "+     3 - Quit                                                         +\n";
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
        | Invalid y -> print_string @@ "Invalid input: " ^ y ^ "\n";
      end
    | None -> print_string "\nNo input detected. Exiting menu.\n"; quit := true
  done

let perform_db_menu_selection (choice: int) (quit: bool ref) = 
  match choice with
  | 1 -> failwith "Case 1: Unimplemented"
  | 2 -> failwith "Case 2: Unimplemented"
  | 3 -> print_string "Leaving the database admin and returning to the main menu....\n"; quit := true
  | _ -> failwith "Unreachable case: user menu choice should already be validated at this point."

let perform_main_menu_selection (choice: int) (quit: bool ref) = 
  match choice with
  | 1 -> failwith "TODO: allow user to query a player's data"
  | 2 -> failwith "TODO: allow user to predict HOF for a certain player"
  | 3 -> print_string "Goodbye.\n"; quit := true
  | 42 -> menu_choice_loop print_db_menu db_admin_menu_choices perform_db_menu_selection ~prompt_prefix:"db"
  | _ -> failwith "Unreachable case: user menu choice should already be validated at this point."


let run_main_menu_loop () = 
  menu_choice_loop print_main_menu main_menu_choices perform_main_menu_selection





let parse_player_selection (_: string) = 
  failwith "Unimplemented"

let player_disambiguation (_: string) =
  failwith "Unimplemented"