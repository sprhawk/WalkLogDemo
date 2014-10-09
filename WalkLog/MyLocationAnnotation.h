//
//  MyLocationAnnotation.h
//  WalkLog
//
//  Created by YANG HONGBO on 2014-9-30.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum AnnotationType {
    AnnotationTypeEarth,
    AnnotationTypeCalculated,
    AnnotationTypeLookup,
}AnnotationType;

@interface MyLocationAnnotation : MKPointAnnotation
@property (nonatomic, assign, readwrite) AnnotationType type;
@end
