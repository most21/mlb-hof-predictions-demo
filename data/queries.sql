-- Get the playerID for a given player name, or return multiple possibilities if ambiguous
SELECT DISTINCT
    P.playerID, 
    (P.nameFirst || ' ' || P.nameLast) as nameFull,
    P.debut,
    P.finalGame,
    A.isPitcher
FROM 
    People as P, 
    Advanced as A
WHERE
    P.bbrefID = A.bbrefID AND
    nameFull = '%s';

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
    P.playerID = 'martijd02' AND 
    P.bbrefID = A.bbrefID AND 
    A.isPitcher = 'N' AND 
    P.playerID = B.playerID AND 
    B.yearID = A.yearID AND B.stint = A.stint;

-- Get offensive data for a certain playerID but collapse stints with multiple teams in 1 season
SELECT 
    B.playerID, 
    B.yearID, 
    B.stint, 
    GROUP_CONCAT(B.teamID) as teamID, 
    B.lgID,
    sum(B.G) as G, 
    sum(B.AB) as AB, 
    sum(B.R) as R, 
    sum(B.H) as H, 
    sum(B._2B) as _2B, 
    sum(B._3B) as _3B, 
    sum(B.HR) as HR, 
    sum(B.RBI) as RBI, 
    sum(B.SB) as SB, 
    sum(B.CS) as CS, 
    sum(B.BB) as BB, 
    sum(B.SO) as SO, 
    sum(B.IBB) as IBB, 
    sum(B.HBP) as HBP, 
    sum(B.SH) as SH, 
    sum(B.SF) as SF, 
    sum(B.GIDP) as GIDP, 
    ROUND(sum(A.wRC_plus * B.G) / sum(B.G), 1) as wRC_plus, 
    sum(A.bWAR162) as bWAR162, 
    sum(A.WAR162) as WAR162
FROM 
    People as P, 
    Batting as B, 
    Advanced as A 
WHERE 
    P.playerID = 'martijd02' AND 
    P.bbrefID = A.bbrefID AND 
    A.isPitcher = 'N' AND 
    P.playerID = B.playerID AND 
    B.yearID = A.yearID AND 
    B.stint = A.stint 
GROUP BY B.yearID;


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
    Pp.playerID = 'scherma01' AND 
    Pp.bbrefID = A.bbrefID AND 
    A.isPitcher = 'Y' AND 
    Pp.playerID = P.playerID AND 
    P.yearID = A.yearID AND P.stint = A.stint;

-- Get pitching data for a certain playerID  but collapse stints with multiple teams
SELECT 
    Pp.playerID, 
    P.yearID, 
    P.stint, 
    GROUP_CONCAT(P.teamID) as teamID, 
    P.lgID,
    sum(P.W) as W, 
    sum(P.L) as L, 
    sum(P.G) as G, 
    sum(P.GS) as GS, 
    sum(P.CG) as CG, 
    sum(P.SHO) as SHO, 
    sum(P.SV) as SV, 
    sum(P.IPouts) as IPouts, 
    sum(P.H) as H, 
    sum(P.ER) as ER, 
    sum(P.HR) as HR, 
    sum(P.BB) as BB, 
    sum(P.SO) as SO, 
    ROUND(sum(P.BAOpp * P.IPouts) / sum(P.IPouts), 3) as BAOpp, 
    ROUND(sum(P.ERA * P.IPouts) / sum(P.IPouts), 2) as ERA, 
    sum(P.IBB) as IBB, 
    sum(P.WP) as WP, 
    sum(P.HBP) as HBP,
    sum(P.BK) as BK,
    ROUND(sum(P.BFP * P.IPouts) / sum(P.IPouts)) as BFP,
    sum(P.GF) as GF,
    sum(P.R) as R,
    sum(P.SH) as SH,
    sum(P.SF) as SF,
    sum(P.GIDP) as GIDP,
    ROUND(sum(A.ERA_minus * P.IPouts) / sum(P.IPouts), 1) as ERA_minus,
    ROUND(sum(A.xFIP_minus * P.IPouts) / sum(P.IPouts), 1) as xFIP_minus,
    sum(A.pWAR162) as pWAR162,  
    sum(A.WAR162) as WAR162
FROM 
    People as Pp, 
    Advanced as A, 
    Pitching as P
WHERE 
    Pp.playerID = 'verlaju01' AND 
    Pp.bbrefID = A.bbrefID AND 
    A.isPitcher = 'Y' AND 
    Pp.playerID = P.playerID AND 
    P.yearID = A.yearID AND P.stint = A.stint
GROUP BY P.yearID;


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


-- Get 10 nearest batters by peak WAR total
SELECT DISTINCT 
    Pp.playerID, 
    Pp.nameFirst, 
    Pp.nameLast, 
    P.peakWar, 
    R.peakWar as targetWar, 
    R.peakWar - P.peakWar as diff
FROM 
    People as Pp,
    Peak as P, 
    Advanced as A,
    (SELECT peakWar FROM Peak WHERE playerID = 'troutmi01') as R
WHERE 
    Pp.playerID = P.playerID AND
    Pp.bbrefID = A.bbrefID AND
    A.isPitcher = 'N' AND
    P.playerID <> 'troutmi01'
ORDER BY ABS(diff) ASC LIMIT 10;

-- Get 10 nearest batters by peak WAR total
SELECT DISTINCT 
    Pp.playerID, 
    Pp.nameFirst, 
    Pp.nameLast, 
    P.peakWar, 
    R.peakWar as targetWar, 
    R.peakWar - P.peakWar as diff
FROM 
    People as Pp,
    Peak as P, 
    Advanced as A,
    (SELECT peakWar FROM Peak WHERE playerID = 'scherma01') as R
WHERE 
    Pp.playerID = P.playerID AND
    Pp.bbrefID = A.bbrefID AND
    A.isPitcher = 'Y' AND
    P.playerID <> 'scherma01'
ORDER BY ABS(diff) ASC LIMIT 10;

-- Check if player is a HOFer (Yes if query returns 1. If 0, then no)
SELECT 'koufasa01' IN (SELECT playerID FROM HallOfFame WHERE inducted = 'Y') as HOF


-- Get career offensive data for all players. Lean format, ready to be converted to matrix for KNN
SELECT 
    P.playerID,
    sum(B.G) as G, 
    sum(B.AB) as AB, 
    sum(B.R) as R, 
    sum(B.H) as H, 
    sum(B._2B) as _2B, 
    sum(B._3B) as _3B, 
    sum(B.HR) as HR, 
    sum(B.RBI) as RBI, 
    sum(B.SB) as SB, 
    sum(B.CS) as CS, 
    sum(B.BB) as BB, 
    sum(B.SO) as SO, 
    sum(B.IBB) as IBB, 
    sum(B.HBP) as HBP, 
    sum(B.SH) as SH, 
    sum(B.SF) as SF, 
    sum(B.GIDP) as GIDP, 
    IFNULL(ROUND(sum(A.wRC_plus * B.G) / sum(B.G), 1), -10000) as wRC_plus, 
    sum(A.bWAR162) as bWAR162
FROM 
    People as P, 
    Advanced as A, 
    Batting as B 
WHERE 
    P.finalGame < '2015-12-31' AND
    P.bbrefID = A.bbrefID AND 
    A.isPitcher = 'N' AND 
    P.playerID = B.playerID AND 
    B.yearID = A.yearID AND B.stint = A.stint
GROUP BY P.playerID;


-- Get career pitching data for all players. Lean format, ready to be converted to matrix for KNN
SELECT 
    Pp.playerID,
    sum(P.W) as W, 
    sum(P.L) as L, 
    sum(P.G) as G, 
    sum(P.GS) as GS, 
    sum(P.CG) as CG, 
    sum(P.SHO) as SHO, 
    sum(P.SV) as SV, 
    sum(P.IPouts) as IPouts, 
    sum(P.H) as H, 
    sum(P.ER) as ER, 
    sum(P.HR) as HR, 
    sum(P.BB) as BB, 
    sum(P.SO) as SO, 
    IFNULL(ROUND(sum(P.BAOpp * P.IPouts) / sum(P.IPouts), 3), -1) as BAOpp, 
    IFNULL(ROUND(sum(P.ERA * P.IPouts) / sum(P.IPouts), 2), -1) as ERA, 
    sum(P.IBB) as IBB, 
    sum(P.WP) as WP, 
    sum(P.HBP) as HBP,
    sum(P.BK) as BK,
    sum(P.GF) as GF,
    sum(P.R) as R,
    sum(P.SH) as SH,
    sum(P.SF) as SF,
    sum(P.GIDP) as GIDP,
    IFNULL(ROUND(sum(A.ERA_minus * P.IPouts) / sum(P.IPouts), 1), -10000) as ERA_minus,
    IFNULL(ROUND(sum(A.xFIP_minus * P.IPouts) / sum(P.IPouts), 1), -10000) as xFIP_minus,
    sum(A.pWAR162) as pWAR162
FROM 
    People as Pp, 
    Advanced as A, 
    Pitching as P
WHERE 
    P.finalGame < '2015-12-31' AND
    Pp.bbrefID = A.bbrefID AND 
    A.isPitcher = 'Y' AND 
    Pp.playerID = P.playerID AND 
    P.yearID = A.yearID AND P.stint = A.stint
GROUP BY Pp.playerID;









SELECT 
    Pp.playerID,
    sum(P.W) as W, 
    sum(P.L) as L, 
    sum(P.G) as G, 
    sum(P.GS) as GS, 
    sum(P.CG) as CG, 
    sum(P.SHO) as SHO, 
    sum(P.SV) as SV, 
    sum(P.IPouts) as IPouts, 
    sum(P.H) as H, 
    sum(P.ER) as ER, 
    sum(P.HR) as HR, 
    sum(P.BB) as BB, 
    sum(P.SO) as SO, 
    IFNULL(ROUND(sum(P.BAOpp * P.IPouts) / sum(P.IPouts), 3), -1) as BAOpp, 
    IFNULL(ROUND(sum(P.ERA * P.IPouts) / sum(P.IPouts), 2), -1) as ERA, 
    sum(P.IBB) as IBB, 
    sum(P.WP) as WP, 
    sum(P.HBP) as HBP,
    sum(P.BK) as BK,
    sum(P.GF) as GF,
    sum(P.R) as R,
    sum(P.SH) as SH,
    sum(P.SF) as SF,
    sum(P.GIDP) as GIDP,
    IFNULL(ROUND(sum(A.ERA_minus * P.IPouts) / sum(P.IPouts), 1), -10000) as ERA_minus,
    IFNULL(ROUND(sum(A.xFIP_minus * P.IPouts) / sum(P.IPouts), 1), -10000) as xFIP_minus,
    sum(A.pWAR162) as pWAR162
FROM 
    People as Pp, 
    Advanced as A, 
    Pitching as P
WHERE 
    Pp.playerID = 'santajo01' AND
    Pp.bbrefID = A.bbrefID AND 
    A.isPitcher = 'Y' AND 
    Pp.playerID = P.playerID AND 
    P.yearID = A.yearID AND P.stint = A.stint;



SELECT 
    Pp.playerID,
    P.W as W, 
    P.L as L, 
    P.G as G, 
    P.GS as GS, 
    P.CG as CG, 
    P.SHO as SHO, 
    P.SV as SV, 
    P.IPouts as IPouts, 
    P.H as H, 
    P.ER as ER, 
    P.HR as HR, 
    P.BB as BB, 
    P.SO as SO, 
    P.BAOpp as BAOpp, 
    P.ERA as ERA, 
    P.IBB as IBB, 
    P.WP as WP, 
    P.HBP as HBP,
    P.BK as BK,
    P.GF as GF,
    P.R as R,
    P.SH as SH,
    P.SF as SF,
    P.GIDP as GIDP,
    A.ERA_minus as ERA_minus,
    A.xFIP_minus as xFIP_minus,
    A.pWAR162 as pWAR162
FROM 
    People as Pp, 
    Advanced as A, 
    Pitching as P
WHERE 
    Pp.playerID = 'santajo01' AND
    Pp.bbrefID = A.bbrefID AND 
    A.isPitcher = 'Y' AND 
    Pp.playerID = P.playerID AND 
    P.yearID = A.yearID AND P.stint = A.stint;