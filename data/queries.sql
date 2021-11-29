-- Get the playerID for a given player name, or return multiple possibilities if ambiguous
SELECT 
    playerID, 
    (nameFirst || ' ' || nameLast) as nameFull,
    debut,
    finalGame
FROM 
    People as P 
WHERE nameFull = '%s';

-- Get offensive data for a certain playerID (%s)
SELECT 
    B.playerID, 
    B.yearID, 
    B.stint, 
    B.teamID, 
    B.lgID,
    B.G, 
    B.AB, 
    B.R, 
    B.H, 
    B._2B, 
    B._3B, 
    B.HR, 
    B.RBI, 
    B.SB, 
    B.CS, 
    B.BB, 
    B.SO, 
    B.IBB, 
    B.HBP, 
    B.SH, 
    B.SF, 
    B.GIDP, 
    A.wRC_plus, 
    A.bWAR162, 
    A.WAR162 
FROM 
    People as P, 
    Advanced as A, 
    Batting as B 
WHERE 
    P.playerID = '%s' AND 
    P.bbrefID = A.bbrefID AND 
    A.isPitcher = 'N' AND 
    P.playerID = B.playerID AND 
    B.yearID = A.yearID AND B.stint = A.stint;

-- Get pitching data for a certain playerID
SELECT 
    Pp.playerID, 
    P.yearID, 
    P.stint, 
    P.teamID, 
    P.lgID,
    P.W, 
    P.L, 
    P.G, 
    P.GS, 
    P.CG, 
    P.SHO, 
    P.SV, 
    P.IPouts, 
    P.H, 
    P.ER, 
    P.HR, 
    P.BB, 
    P.SO, 
    P.BAOpp, 
    P.ERA, 
    P.IBB, 
    P.WP, 
    P.HBP,
    P.BK,
    P.BFP,
    P.GF,
    P.R,
    P.SH,
    P.SF,
    P.GIDP,
    A.ERA_minus,
    A.xFIP_minus,
    A.pWAR162,  
    A.WAR162 
FROM 
    People as Pp, 
    Advanced as A, 
    Pitching as P
WHERE 
    Pp.playerID = '%s' AND 
    Pp.bbrefID = A.bbrefID AND 
    A.isPitcher = 'Y' AND 
    Pp.playerID = P.playerID AND 
    P.yearID = A.yearID AND P.stint = A.stint;


-- Get a list of the 3 teams where a pitcher spent the most total seasons, in descending order.
SELECT
    GROUP_CONCAT(R.teamID) as mainTeams 
FROM 
    (
        SELECT teamID, count(teamID) as seasonCount 
        FROM Pitching as P 
        WHERE P.playerID = '%s' 
        GROUP BY teamID 
        ORDER BY seasonCount DESC 
        LIMIT 3
    ) as R;


-- Get a list of the 3 teams where a batter spent the most total seasons, in descending order.
SELECT
    GROUP_CONCAT(R.teamID) as mainTeams 
FROM 
    (
        SELECT teamID, count(teamID) as seasonCount 
        FROM Batting
        WHERE playerID = '%s' 
        GROUP BY teamID 
        ORDER BY seasonCount DESC 
        LIMIT 3
    ) as R;


