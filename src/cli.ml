open Core
(* open Owl *)

type input = MenuOption of int |  Invalid of string (* | Player of string *)

let print_main_menu () = 
  print_string "+======================================================================+\n";
  print_string "+ Welcome to the MLB Hall of Fame prediction engine. Select an option: +\n";
  print_string "+     1 - View player data                                             +\n";
  print_string "+     2 - Predict HOF candidacy for a player                           +\n";
  print_string "+     3 - Quit                                                         +\n";
  print_string "+     42 - Super Secret Database Admin Panel                           +\n";
  print_string "+======================================================================+\n";
  print_string "> ";
  Out_channel.flush stdout;
  ()

let parse_menu_choice (s: string) : input = 
  let is_int str = 
    try Int.of_string str |> fun _ -> true with
    | Failure _ -> false
  in
  match s with
  | _ when is_int s -> 
    begin
      match Int.of_string s with
      | x when x = 1 || x = 2 || x = 3 || x = 42 -> MenuOption x
      | _ -> Invalid s
    end
  | _ -> Invalid s

let menu_choice_loop () = 
  print_main_menu ();
  match In_channel.input_line In_channel.stdin with
  | Some s -> 
    begin
      match parse_menu_choice s with
      | MenuOption x -> print_string @@ "You selected " ^ (Int.to_string x) ^ "\n";
      | Invalid y -> print_string @@ "Invalid input: " ^ y ^ "\n";
    end
  | None -> print_string "No input detected. Try again.\n"

let parse_player_selection (_: string) = 
  failwith "Unimplemented"

let player_disambiguation (_: string) =
  failwith "Unimplemented"