(* open Core *)

type input

val menu_choice_loop : unit -> unit

val print_main_menu : unit -> unit

(* Validate/parse user input for menu option selection  *)
val parse_menu_choice : string -> input

(* 
    Validate/parse user input for the player being queried. 
    Takes the name of the player as typed by the user and finds the proper playerID for querying the database.
*)
val parse_player_selection : string -> string

(* Given the name of a player that is not unique, list all players and prompt the user to clarify. *)
val player_disambiguation : string -> string