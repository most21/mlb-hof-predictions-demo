CREATE TABLE People (
    playerID TEXT PRIMARY KEY,
    birthYear INTEGER,
    birthMonth INTEGER,
    birthDay INTEGER,
    birthCountry TEXT,
    birthState TEXT,
    birthCity TEXT,
    deathYear INTEGER,
    deathMonth INTEGER,
    deathDay INTEGER,
    deathCountry TEXT,
    deathState TEXT,
    deathCity TEXT,
    nameFirst TEXT,
    nameLast TEXT,
    nameGiven TEXT,
    weight INTEGER,
    height INTEGER,
    bats TEXT,
    throws TEXT,
    debut TEXT,
    finalGame TEXT,
    retroID TEXT,
    bbrefID TEXT
);

CREATE TABLE TeamsFranchises (
    franchID TEXT PRIMARY KEY,
    franchName TEXT NOT NULL,
    active TEXT,
    NAassoc TEXT
);