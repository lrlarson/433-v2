//
//  LatLong.h
//  FourThirtyThree
//
//  Created by Phil Stone on 12/14/13.
//  Copyright (c) 2013 John Cage Trust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LatLong : NSObject {
    double latitude;
    double longitude;
}

@property (readonly) double latitude;
@property (readonly) double longitude;

+ (id)latLongWithLatitude:(double)_lat
                longitude:(double)_lon;
- (id)initWithLatitude:(double)_lat
             longitude:(double)_lon;

@end
