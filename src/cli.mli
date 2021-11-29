(* open Core *)

type input

(* Run the main loop for the program, which displays the main menu. Basically just a wrapper around menu_choice_loop *)
val run_main_menu_loop : unit -> unit

(* 
    Validate/parse user input for menu option selection.
    Args: string containing the line of user input and an int list containing possible legal menu options.
*)
val parse_menu_choice : string -> int list -> input

(* 
    Run a general menu loop where the user can choose from a set of integer options. 
    Takes a function as an argument that prints the desired menu.
*)
val menu_choice_loop : ?prompt_prefix:string -> (unit -> unit) -> int list -> (int -> bool ref -> unit) -> unit

(* Function that handles the database admin menu selection. *)
val perform_db_menu_selection : int -> bool ref -> unit

(* Function that handles the main menu selection. *)
val perform_main_menu_selection : int -> bool ref -> unit

(* Function that handles the user selection when disambiguating players with the same name. *)
val perform_player_disambiguation_selection : int -> bool ref -> unit

(* 
    Validate/parse user input for the player being queried. 
    Takes the name of the player as typed by the user and finds the proper playerID for querying the database.
*)
val parse_player_selection : string -> string

(* Given the name of a player that is not unique, list all players and prompt the user to clarify. *)
val player_disambiguation : string -> string