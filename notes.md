notes.md


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
