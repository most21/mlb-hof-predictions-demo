# mlb-hof-predictions

Repository: https://github.com/most21/mlb-hof-predictions

## Purpose
The goal of this project is to create a tool that can predict future Major League Baseball (MLB) Hall of Fame (HOF) inductees. The project can be broken down into three main phases with one stretch phase:

1. Create a database of baseball statistics that specifically focuses on HOF players.

2. Develop methods to predict whether a player will be inducted into the HOF. The project will attempt three different algorithms:

   a. A peak-WAR (WAR is a common statistic to measure value) estimation system that extracts a player’s best years and compares them to existing HOFers. This is similar to Jay Jaffe’s [JAWS](https://www.mlb.com/glossary/miscellaneous/jaws) system. This method is not a probabilistic model and thus only provides a soft indication of a player's HOF worthiness.

   b.   A K-Nearest-Neighbors (KNN) model that predicts HOF candidacy for players, either based on their entire career statistics or their peak-WAR data from the previous part.

   c.   (STRETCH GOAL) A neural network autoencoder that will be used to create dense vector embeddings for each player which can then be compared using cosine similarity.

3. Build a command-line tool to interact with the above functionality. Users should be able to view a player’s data, make a prediction for a player using each method, and visualize how close this player is to other players.

## Progress
As of 12/6/2021, the database has been built and the peak-WAR system (2a) has been implemented. The command line has been built out to support existing functionality.

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

## Data Sources
All data is publicly available and was downloaded in .csv format. Some light cleaning was done in Python (e.g. to resolve latin alphabet characters and handle missing values). This code can be found in `src/misc.py`.
1. A selection of tables from the Sean Lahman Database, accessible here: http://www.seanlahman.com/baseball-archive/statistics/
2. WAR data, courtesy of Neil Paine of 538. The data can be found here: https://github.com/NeilPaine538/MLB-WAR-data-historical

## Directory Structure

- `src/` contains all source code (Ocaml, Python)
- `data/` contains the clean and raw data files (.csv), the database schema, and a doc containing some important database queries (SQL)
- `tests/` contains the test files for the project
- The database file used for SQLite is called `mlb-hof.db`
