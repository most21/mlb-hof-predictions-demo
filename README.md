# mlb-hof-predictions

Presentation slide deck: https://docs.google.com/presentation/d/13epTXxoR_98UWV5akfgNNTISKj_POZzSUw2n1vHUCCA/edit?usp=sharing

## Purpose
The goal of this project is to create a tool that can predict future Major League Baseball (MLB) Hall of Fame (HOF) inductees. The project can be broken down into three main phases with one stretch phase:

1. Create a database of baseball statistics that specifically focuses on HOF players.

2. Develop methods to predict whether a player will be inducted into the HOF. The project will attempt two different algorithms:

   a. A peak-WAR (WAR is a common statistic to measure value) estimation system that extracts a player’s best years and compares them to existing HOFers. This is similar to Jay Jaffe’s [JAWS](https://www.mlb.com/glossary/miscellaneous/jaws) system. This method is not a probabilistic model and thus only provides a soft indication of a player's HOF worthiness.

   b.   A K-Nearest-Neighbors (KNN) model that predicts HOF candidacy for players, either based on their entire career statistics or their peak-WAR data from the previous part.

3. Build a command-line tool to interact with the above functionality. Users should be able to view a player’s data, make a prediction for a player using each method, and visualize how close this player is to other players.

## Progress
As of 12/14/2021, the database has been built, the peak-WAR system (2a) and the KNN model (2b) have been implemented. The command line has been built out to support existing functionality.

## Requirements
- OCaml 4.12.0
- Core
- sqlite3-ocaml
- Owl

## Install + Run
- Clone the repository
```shell
git clone https://github.com/most21/mlb-hof-predictions.git
cd mlb-hof-predictions/
```

- Set environment variable for the database file. The variable must be called `HOF_DB_FILE` and it must contain the **absolute** path to the `mlb-hof.db` file on your system. This is crucial, otherwise the application cannot be built or tested.
```shell
export HOF_DB_FILE="ABSOLUTE_PATH_TO_DB/mlb-hof.db"
```

- Build the application
```shell
dune build
```

- Run the command line interface via the `main` executable
```shell
dune exec ./src/main.exe
```

- Optionally, run the test suite
```shell
dune test
```

Players to experiment with: Max Scherzer, Mike Trout, Sandy Koufax, Clayton Kershaw, Albert Pujols, and more!

## Data Sources
All data is publicly available and was downloaded in .csv format. Some light cleaning was done in Python (e.g. to resolve latin alphabet characters and handle missing values). This code can be found in `src/misc.py`.
1. A selection of tables from the Sean Lahman Database, accessible here: http://www.seanlahman.com/baseball-archive/statistics/
2. WAR data, courtesy of Neil Paine of 538. The data can be found here: https://github.com/NeilPaine538/MLB-WAR-data-historical

## Directory Structure

- `src/` contains all source code (Ocaml, Python)
   - `src/cli.*` files have the relevant code for the command line interface
   - `src/dataframe_utils.*` files have some handy utility functions for working with Owl Dataframes
   - `src/database.*` files contain the many functions that interact with the database directly, including data getter functions for the different analytical methods.
   - `src/jaws.*` files contain the logic for the peak-WAR (JAWS) prediction method
   - `src/knn.*` files contain the logic for the kNN prediction method  
- `data/` contains the clean and raw data files (.csv), the database schema, and a doc containing some important database queries (SQL)
- `tests/` contains the test files for the project
- The database file used for SQLite is called `mlb-hof.db`
