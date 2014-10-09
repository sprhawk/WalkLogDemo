-- Version 1
create table if not exists locations
                                    (latitude real,
                                    longitude real,
                                    haccuracy real,
                                    altitude real,
                                    vaccuracy real,
                                    course real,
                                    speed real,
                                    timestamp integer,
                                    foreground integer);


