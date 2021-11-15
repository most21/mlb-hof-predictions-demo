open Core
open Owl

type player = {id: string; data: Dataframe.t}

val print_main_menu : unit -> unit

val parse_menu_choice : string -> int

val parse_player_selection : string -> player