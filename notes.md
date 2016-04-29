notes.md

## correlations / importance

dumb accuracy seems to be around ~60% on shot distance alone.

combined_shot_type won the preliminary rfe. huh???
followed by shot_distance, shot_zone_basic

some basic variable importance

shot_distance                         100.00
combined_shot_typeDunk                 62.11
combined_shot_typeJump Shot            49.58
period                                 38.22
shot_zone_basicRestricted Area         37.25
shot_type3PT Field Goal                28.14
shot_zone_range24+ ft.                 20.94
shot_zone_rangeLess Than 8 ft.         19.39
shot_zone_areaCenter(C)                17.66
combined_shot_typeLayup                17.12
shot_zone_basicMid-Range               16.93
season2005-06                          16.46
shot_zone_basicIn The Paint (Non-RA)   15.96
season2015-16                          14.91
playoffsTRUE                           12.39
season2007-08                          12.28
season2006-07                          11.18
season1999-00                          10.96
season2010-11                          10.38
season2004-05                          10.32

> prop.table(table(prepped$playoffs, prepped$shot_made_flag), 1)

             Miss      Make
  FALSE 0.5535804 0.4464196
  TRUE  0.5553486 0.4446514

> prop.table(table(prepped$shot_zone_area, prepped$shot_made_flag),1)

                              Miss       Make
  Back Court(BC)        0.98611111 0.01388889
  Center(C)             0.47444415 0.52555585
  Left Side Center(LC)  0.63882283 0.36117717
  Left Side(L)          0.60312899 0.39687101
  Right Side Center(RC) 0.61743281 0.38256719
  Right Side(R)         0.59834154 0.40165846

> prop.table(table(prepped$away, prepped$shot_made_flag),1)

             Miss      Make
  FALSE 0.5435322 0.4564678
  TRUE  0.5635786 0.4364214

> prop.table(table(data.train$combined_shot_type, data.train$shot_made_flag),1)

                 Miss      Make
  Bank Shot 0.2083333 0.7916667
  Dunk      0.0719697 0.9280303
  Hook Shot 0.4645669 0.5354331
  Jump Shot 0.6089295 0.3910705
  Layup     0.4349073 0.5650927
  Tip Shot  0.6513158 0.3486842

> prop.table(table(data.train$shot_zone_basic, data.train$shot_made_flag),1)

                               Miss      Make
  Above the Break 3     0.67076271 0.32923729
  Backcourt             0.98333333 0.01666667
  In The Paint (Non-RA) 0.54561856 0.45438144
  Left Corner 3         0.62916667 0.37083333
  Mid-Range             0.59371439 0.40628561
  Restricted Area       0.38199595 0.61800405
  Right Corner 3        0.66066066 0.33933934

> prop.table(table(prepped$shot_zone_range, prepped$shot_made_flag),1)

                        Miss       Make
  16-24 ft.       0.59823368 0.40176632
  24+ ft.         0.66748722 0.33251278
  8-16 ft.        0.56451613 0.43548387
  Back Court Shot 0.98611111 0.01388889
  Less Than 8 ft. 0.42688049 0.57311951

take aways:
playoffs are not a helpful indicator.
away seems like a meaningful indicator
shot_type is described by shot_zone_basic
shot_zone_range is described by shot_distance

## feature engineering

lots of munging that has to happen. specifically, need to grab data from only before a given shot, not after.

need to calculate "previous" FG.
 --- time frame? previous games?
 --- what is previous? matching shot type? zone? distance?

### obviously garbage columns:
game_event_id
game_id
team_id
team_name
shot_id


### possibly garbage columns:
lat
loc_x
loc_y
lon

###obviously garbage columns that can be engineered:

* action_type (jump shot, layup shot, etc.) lots of levels! 57! too many! perhaps can group into categories -- Alley Oop, Cutting, Driving, Fadeaway, Follow/Tip/Putback, Pullup, Reverse, Running, Slam/Dunk, Step Back, Turnaround, NA
* game-date (use to identify time)
* matchup (use to identify home or away)
* opponent (can we point to an SRS score?)
* minutes_remaining (in quarter) + seconds_remaining (in seconds) (can probably be combined to decide if it's a heave., with quarter, can be combined to find out if it's a clutch shot)

### perhaps good columns:
combined_shot_type (bank shot, layup, etc.) fewer levels
shot_type (2 or 3)

-- shot zone/distance stats
shot_zone_area (directional. perhaps can be used to idenify position)
shot_zone_basic (non-directional)
shot_zone_range (range, non-directional)
shot_distance

period (goes up to 7! use to identify three categories -- 1-3, 4, OT)
playoffs
season -- necessary for engineered features

target:
shot_made_flag


let's do some descriptive stats!!!
