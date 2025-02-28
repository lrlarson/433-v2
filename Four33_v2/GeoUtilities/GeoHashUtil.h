//
//  GeoHashUtil.h
//  FourThirtyThree
//
//  Created by Phil Stone on 12/13/13.
//  Copyright (c) 2013 John Cage Trust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coverage.h"

@interface GeoHashUtil : NSObject

+ (Coverage *) coverBoundingBoxTopLeftLat: (double)topLeftLat
                               topLeftLon: (double)topLeftLon
                           bottomRightLat: (double)bottomRightLat
                           bottomRightLon: (double)bottomRightLon
                                maxHashes: (int)maxHashes;

+ (double)calculateHeightDegrees:(int)hashLength;
+ (double)calculateWidthDegrees:(int)hashLength;
+ (double)longitudeDiff:(double)lng1 longitude2:(double)lng2;
+ (double)to180:(double)d;

@end
