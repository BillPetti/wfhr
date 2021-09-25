# `wfhr` 0.1.0

`wfhr` is an R package built to make acquiring NCAA Women’s Field Hockey data simple.

You can install the package via:

``` r
library(devtools)	

devtools::install_github("BillPetti/wfhr")
```

## Functions

Currently, the package contains three functions:

`get_ncaa_wfh_team_schedules()`: used to acquire game schedule and
results for a team in a given year.

`get_ncaaa_wfh_team_roster()`: used to acquire team rosters in a given year.

Both of these functions should work on seasons back to the 2014-2015 season.

`school_lu()`: used to quickly lookup school IDs and other information.

## Data

The package contains a few internal data sets to make the user’s life
easier.

`fh_master_lu_table`: A data frame that includes school name, ID,
conference, conference ID, and division by year. Goes back to 2010.
Please note that there are likely some errors where the NCAA has teams
listed as either in two divisions or, due to being an Indepedent team,
they will appear to be in all three divisions in a single season. I’ve
tried to minimize this by restricting the data to 2010-present, but
there are still some duplicates.

`fh_year_lu_table`: A helper data set that contains the season
codes used by the NCAA for field hockey seasons.

## Usage

First, say you are interested in UConn. You
can use the `school_lu` function to find their NCAA stats ID:

``` r
school_lu(school_name = 'Maryland',
          school_division = 1)
school school_id  year division conference_id conference
   <chr>      <dbl> <dbl>    <dbl>         <dbl> <chr>     
 1 UConn        164  2010        1           823 AAC       
 2 UConn        164  2011        1           823 AAC       
 3 UConn        164  2012        1           823 AAC       
 4 UConn        164  2013        1           823 AAC       
 5 UConn        164  2014        1         30184 Big East  
 6 UConn        164  2015        1         30184 Big East  
 7 UConn        164  2016        1         30184 Big East  
 8 UConn        164  2017        1         30184 Big East  
 9 UConn        164  2018        1         30184 Big East  
10 UConn        164  2019        1         30184 Big East  
11 UConn        164  2020        1         30184 Big East  
12 UConn        164  2021        1         30184 Big East  
13 UConn        164  2022        1         30184 Big East 
```
This returns all records in the `fh_master_lu_table` data set
where ‘UConn’ is in the school name and the teams are listed in
division 1. You can see that UCOnn has switched conferences over the
years from the ACC to the Big East. We also see that UConn’s
`school_id` is 392. We’ll need that `school_id` for the rest of the
functions.

Next, let’s acquire UConn’s schedule for the 2017-2018, the year they won the National Championship. (Note: for `year` we must put 2018 because the season was 2017-2018):

``` r
get_ncaa_wfh_team_schedules(team_id = 164, 
                                        year = 2018)
                                        
    team conference conference_id division       date       opponent result attendance
1  UConn   Big East         30184        1 2017-08-25       Stanford      W         NA
2  UConn   Big East         30184        1 2017-08-27   Northwestern      W         NA
3  UConn   Big East         30184        1 2017-09-03       Michigan      W         NA
4  UConn   Big East         30184        1 2017-09-08        Pacific      W         NA
5  UConn   Big East         30184        1 2017-09-10        Harvard      W         NA
6  UConn   Big East         30184        1 2017-09-15   Old Dominion      W         NA
7  UConn   Big East         30184        1 2017-09-17      Boston U.      W         NA
8  UConn   Big East         30184        1 2017-09-22         Temple      W         NA
9  UConn   Big East         30184        1 2017-09-24       Delaware      W         NA
10 UConn   Big East         30184        1 2017-09-29     Providence      W         NA
11 UConn   Big East         30184        1 2017-10-01  Massachusetts      W         NA
12 UConn   Big East         30184        1 2017-10-06      Villanova      W         NA
13 UConn   Big East         30184        1 2017-10-08      Princeton      W         NA
14 UConn   Big East         30184        1 2017-10-14        Liberty      W         NA
15 UConn   Big East         30184        1 2017-10-21     Georgetown      W         NA
16 UConn   Big East         30184        1 2017-10-27     Quinnipiac      W         NA
17 UConn   Big East         30184        1 2017-10-28 Boston College      W         NA
18 UConn   Big East         30184        1 2017-11-03     Providence      W         NA
19 UConn   Big East         30184        1 2017-11-05        Liberty      W         NA
20 UConn   Big East         30184        1 2017-11-11      Boston U.      W         NA
21 UConn   Big East         30184        1 2017-11-12       Penn St.      W         NA
22 UConn   Big East         30184        1 2017-11-17 North Carolina      W         NA
23 UConn   Big East         30184        1 2017-11-19       Maryland      W         NA
   goals_for goals_against location
1          2             0     home
2          7             0     home
3          2             1     away
4          6             2     home
5          3             1     away
6          6             0     home
7          8             1     home
8          4             1     away
9          1             0     away
10         2             0     home
11         8             0     home
12        12             0     away
13         5             3     away
14         3             0     away
15        10             0     home
16         3             1     away
17         3             0     home
18         3             0     away
19         3             0  neutral
20         3             1     home
21         4             3     home
22         2             1  neutral
23         2             1  neutral
```

The function returns a data frame with information about each game
played in that season, including opponents, goals for and against, and
whether the game was played at home, away, or a neutral site.

Finally, let’s say we are interested in UConn’s roster for that season:

``` r
get_ncaa_wfh_team_roster(164, 2018)

    team team_id year conference conference_id jersey                           player pos yr
2  UConn     164 2018   Big East         30184      5                   Albright, Tori   F Fr
3  UConn     164 2018   Big East         30184      7                Alexander, Rachel   F Fr
4  UConn     164 2018   Big East         30184     13                     Alissi, Dina   M Fr
5  UConn     164 2018   Big East         30184      1                   Bleier, Aubrie   F Jr
6  UConn     164 2018   Big East         30184     22                      Boker, Svea   F So
7  UConn     164 2018   Big East         30184     18                   Burns, Natalie   F Fr
8  UConn     164 2018   Big East         30184     11                Colesworthy, Emma   M Fr
9  UConn     164 2018   Big East         30184     10                  Collins, Amanda   F Jr
10 UConn     164 2018   Big East         30184      2              Dembrowski, Jessica   M Fr
11 UConn     164 2018   Big East         30184     17                 Heistand, Karlie   M Sr
12 UConn     164 2018   Big East         30184      9                Iacobucci, Amelia   M Jr
13 UConn     164 2018   Big East         30184     12                Kennedy, Kourtney   F Fr
14 UConn     164 2018   Big East         30184     88                      Klein, Nina  GK Sr
15 UConn     164 2018   Big East         30184     52                    Konerth, Kita  GK So
16 UConn     164 2018   Big East         30184     47                      Lucas, Abby  GK So
17 UConn     164 2018   Big East         30184     30                   McNamara, Erin   B So
18 UConn     164 2018   Big East         30184     14                     Rich, Ashley   M So
19 UConn     164 2018   Big East         30184     24                     Russo, Julia   M So
20 UConn     164 2018   Big East         30184      3                  Schott, Maureen   B Jr
21 UConn     164 2018   Big East         30184     00               Sprecher, Cheyenne  GK Fr
22 UConn     164 2018   Big East         30184     20                 Tiedtke, Antonia   M So
23 UConn     164 2018   Big East         30184     28                  Tucker, Vivenne   M Fr
24 UConn     164 2018   Big East         30184      8                   Umstead, Casey   F Sr
25 UConn     164 2018   Big East         30184     26               Veitner, Charlotte   F Sr
26 UConn     164 2018   Big East         30184      4 van Hecking Colenbrander, Margot   B Fr
27 UConn     164 2018   Big East         30184      6          van den Hoogen, Barbara   M So
   gp gs
2   0  0
3   0  0
4   0  0
5   4  0
6  20 19
7   0  0
8   0  0
9  23 23
10 23 23
11 23 23
12 22 22
13 19  1
14 23 23
15  0  0
16  1  0
17  0  0
18 20  5
19  4  0
20 10  0
21  0  0
22 23 23
23 23  1
24 23 23
25 22 22
26 22 22
27 23 23
```

The function returns a data frame with each individual player, their
class, number, etc.
