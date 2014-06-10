CREATE TABLE workouts (
    name text not null,
    wdate integer not null unique default (strftime('%s',CURRENT_TIMESTAMP)),
    wtypeid integer,
    amount_1 number,
    amount_2 number,
    amount_3 number,
    amount_name_1 text,
    amount_name_2 text,
    amount_name_3 text,
    time_1 number,
    time_2 number,
    time_3 number,
    hrate integer,
    weight number,
    feeling integer,
    weather_t number,
    weather_c number,
    notes text,
    parentid integer,
    rstep integer,
    rtill integer,
    color integer,
    flags integer
);

CREATE INDEX name_index on workouts (name asc);
CREATE INDEX parentid_index on workouts (parentid asc);
CREATE INDEX wdate_index on workouts (wdate asc);

CREATE TABLE metrics (
    wid integer,
    wname text,
    mtype integer,
    mname text,
    metric text
);

CREATE INDEX wid_index on metrics (wid asc);
CREATE INDEX wname_index on metrics (wname asc);
CREATE INDEX mtype_index on metrics (mtype asc);
