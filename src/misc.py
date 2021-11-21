import numpy as np
import pandas as pd
import unidecode

PATH = "./data/"
FILE1 = "jeffbagwell_war_historical"
FILE2 = "jeffbagwell_war_historical_clean"
FILE3 = "People"
EXT = ".csv"
FULL_FILEPATH = PATH + FILE1 + EXT
FULL_FILEPATH_CLEAN = PATH + FILE2 + EXT

def remove_accents():
    """ Replace accented characters in the data. Ex: José --> Jose. """
    # Read file with accents
    with open(FULL_FILEPATH, "r", encoding="latin") as f:
        contents = f.read()

    # Remove accents and make sure there was no data loss
    clean_contents = unidecode.unidecode(contents, errors="strict")
    assert len(contents) == len(clean_contents)

    # Write cleaned file without accents
    with open(FULL_FILEPATH_CLEAN, "w") as f:
        f.write(clean_contents)

def drop_players_and_columns():
    # Read advanced data file (JEFFBAGWELL) and get list of players in the larger dataset
    adv_data = pd.read_csv(FULL_FILEPATH_CLEAN)
    players = list(pd.read_csv(PATH + FILE3 + EXT)["bbrefID"])

    # Select columns we care about
    cols = ["key_bbref", "year_ID", "team_ID", "franch_ID", "stint_ID", "is_P", "g_bat", "bwar162", "wRC_plus", "g_pitch", "pwar162", "ERA_minus", "xFIP_minus", "WAR162"]
    adv_data = adv_data[cols]

    # Take only the rows for players that appear in our dataset. It seems there are some players in the dataset who do not have WAR data.
    adv_data = adv_data[adv_data["key_bbref"].isin(players)]

    # Change column names to match rest of database
    new_col_names = ["bbrefID", "yearID", "teamID", "franchID", "stint", "isPitcher", "gamesBatter", "bWAR162", "wRC_plus", "gamesPitcher", "pWAR162", "ERA_minus", "xFIP_minus", "WAR162"]
    adv_data.columns = new_col_names

    # print(adv_data[adv_data["bbrefID"] == "scherma01"])

    # Write to file
    adv_data.to_csv("./data/Advanced.csv", index=False)

def fill_missing_values_df(df, default_vals):
    """ 
        Fill NaN values in a single dataframe.
        Unfortunately, this cannot be done easily with Owl dataframes b/c columns cannot have mixed types.
        Owl drops rows with missing values rather than storing them as NaN.

        Args:
            df : pandas dataframe, potentially with missing data to fill
            default_vals : dict mapping df column names to an appropriate default value
    """
    # For each column, fill any missing values with some default value
    for col in df.columns:
        if np.sum(df[col].isna()) > 0:
            df[col] = df[col].fillna(default_vals[col])

    return df

def fill_missing_values_wrapper():
    """ Wrapper function that calls fill_missing_values_df() on each file in the list. """
    tables = ["People", "TeamsFranchises", "AwardsPlayers", "AwardsSharePlayers", "Batting", "BattingPost", "HallOfFame", "Pitching", "PitchingPost", "SeriesPost", "Teams", "Advanced"]
    df = pd.read_csv("data/default_values.csv")#.set_index("column", drop=True)
    default_values = {k:v for k, v in zip(list(df["column"]), list(df["value"]))}

    for t in tables:
        print(t)
        df = pd.read_csv("data/raw/" + t + ".csv")
        filled_df = fill_missing_values_df(df, default_values)
        df.to_csv("data/clean/" + t + ".csv", index=False)
        #quit()

if __name__ == "__main__":
    # remove_accents()

    # drop_players_and_columns()

    fill_missing_values_wrapper()
    pass

    


