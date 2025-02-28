//
//  LatLong.m
//  FourThirtyThree
//
//  Created by Phil Stone on 12/14/13.
//  Copyright (c) 2013 John Cage Trust. All rights reserved.
//

#import "LatLong.h"

@implementation LatLong

@synthesize longitude, latitude;

+ (id)latLongWithLatitude:(double)_lat
                longitude:(double)_lon
{
    return [[LatLong alloc] initWithLatitude:_lat
                                   longitude:_lon];
}

- (id)initWithLatitude:(double)_lat
             longitude:(double)_lon
{
    if ((self = [super init]) != nil) {
        latitude = _lat;
        longitude = _lon;
    }
    return self;
}

@end
