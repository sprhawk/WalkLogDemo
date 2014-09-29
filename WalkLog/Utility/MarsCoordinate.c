//
//  MarsCoordinate.c
//  WalkLog
//
//  Created by YANG HONGBO on 2014-9-29.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#include "MarsCoordinate.h"

#include <math.h>

//
// Krasovsky 1940
//
// a = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
const static double a = 6378245.0;
const static double ee = 0.00669342162296594323;


static double mars_transformed_latitude(double x, double y);
static double mars_transformed_longitude(double x, double y);

int mars_corrected_coordinate(double wgs_longitude, double wgs_latitude, double * pgcj_longitude, double *pgcj_latitude)
{
    if ((wgs_longitude < 72.004 || wgs_longitude > 137.8347)
        || (wgs_latitude < 0.8293 || wgs_latitude > 55.8257)) {
        if (pgcj_longitude) {
            *pgcj_longitude = wgs_longitude;
        }
        if (pgcj_latitude) {
            *pgcj_latitude = wgs_latitude;
        }
        return 0;
    }
    
    double lat = mars_transformed_latitude(wgs_longitude - 105.0, wgs_latitude - 35.0);
    double lon = mars_transformed_longitude(wgs_longitude - 105.0, wgs_latitude - 35.0);
    double rad_lat = wgs_latitude / 180.0 * M_PI;
    double magic = sin(rad_lat);
    magic = 1 - ee * magic * magic;
    double sqrt_magic = sqrt(magic);
    lat = (lat * 180.0) / ( (a * (1 - ee)) / (magic * sqrt_magic) * M_PI);
    lon = (lon * 180.0) / ( a / sqrt_magic * cos(rad_lat) * M_PI);
    if (pgcj_longitude) {
        *pgcj_longitude = wgs_longitude + lon;
    }
    if (pgcj_latitude) {
        *pgcj_latitude = wgs_latitude + lat;
    }
    
    return 1;
}

double mars_transformed_latitude(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

double mars_transformed_longitude(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}
