//
//  GeoHashUtil.m
//  FourThirtyThree
//
//  Created by Phil Stone on 12/13/13.
//  Copyright (c) 2013 John Cage Trust. All rights reserved.
//
//  This code is a translation (from Java to Objective-C) of a subset of David Moten's
//   "geo" geohashing utilities (https://github.com/davidmoten/geo) which is released under
//  Apache 2.0 (license available here: http://www.apache.org/licenses/LICENSE-2.0)
//
//  It combines this with the use of some code from https://github.com/lyokato/objc-geohash
//  (basic geohash encoding/decoding -- in the "GeoHash" folder in this project)
//  to save me the time of translating that.
//
//

#import "GeoHashUtil.h"
#import "Coverage.h"
#import "LatLong.h"
#import "GeoHash.h"
#import "GHArea.h"

@implementation GeoHashUtil

#define MAX_HASH_LENGTH 12
#define DEFAULT_MAX_HASHES 12

// Returns the hashes of given length that are required to cover the given bounding box. The
// maximum length of hash is selected that satisfies the number of hashes returned is less
// than maxHashes. Returns nil if hashes cannot be found satisfying that condition.
// Maximum hash length returned will be MAX_HASH_LENGTH
+ (Coverage *) coverBoundingBoxTopLeftLat: (double)topLeftLat
                               topLeftLon: (double)topLeftLon
                           bottomRightLat: (double)bottomRightLat
                           bottomRightLon: (double)bottomRightLon
                                maxHashes: (int)maxHashes
{
    Coverage *coverage = nil;
    
    // Normalize longitude (added by PKS 2013/12/23)
    topLeftLon = [self to180:topLeftLon];
    bottomRightLon = [self to180:bottomRightLon];
    
    int startLength = [GeoHashUtil hashLengthToCoverBoundingBoxWithTopLeftLat:topLeftLat topLeftLon:topLeftLon bottomRightLat:bottomRightLat bottomRightLon:bottomRightLon];
    if (startLength == 0) startLength = 1;
    for (int length = startLength; length <= MAX_HASH_LENGTH; length++) {
        Coverage *c = [GeoHashUtil coverBoundingBoxWithTopLeftLat:topLeftLat topLeftLon:topLeftLon bottomRightLat:bottomRightLat bottomRightLon:bottomRightLon length:length];
        if ([c hashes].count > maxHashes) return coverage;
        else coverage = c;
    }
    return coverage;
}


// Returns the hashes of given length that are required to cover the given bounding box.
+ (Coverage *) coverBoundingBoxWithTopLeftLat: (double)topLeftLat
                                topLeftLon: (double)topLeftLon
                             bottomRightLat: (double)bottomRightLat
                            bottomRightLon: (double)bottomRightLon
                                     length: (int)length
{
    NSAssert(length > 0, @"Hash length must be greater than zero");
    
    double actualWidthDegreesPerHash = [GeoHashUtil calculateWidthDegrees:length];
    double actualHeightDegreesPerHash = [GeoHashUtil calculateHeightDegrees:length];
    
    NSMutableSet *hashes = [[NSMutableSet alloc] init];
    double diff = [GeoHashUtil longitudeDiff:bottomRightLon longitude2:topLeftLon];
    double maxLon = topLeftLon + diff;
    
    // Build set of covering hashes
    for (double lat = bottomRightLat; lat <= topLeftLat; lat += actualHeightDegreesPerHash) {
        for (double lon = topLeftLon; lon <= maxLon; lon += actualWidthDegreesPerHash) {
            [GeoHashUtil addHash:hashes latitude:lat longitude:lon hashLength:length];
        }
    }
    // ensure that the  borders are covered
    for (double lat = bottomRightLat; lat <= topLeftLat; lat += actualHeightDegreesPerHash) {
        [GeoHashUtil addHash:hashes latitude:lat longitude:maxLon hashLength:length];
    }
    for (double lon = topLeftLon; lon <= maxLon; lon += [GeoHashUtil calculateWidthDegrees:length]) {
        [GeoHashUtil addHash:hashes latitude:topLeftLat longitude:lon hashLength:length];
    }
    // ensure that the topRight corner is covered
    [GeoHashUtil addHash:hashes latitude:topLeftLat longitude:maxLon hashLength:length];
    
    double areaDegrees = diff * (topLeftLat - bottomRightLat);
    double coverageAreaDegrees = [hashes count] * [GeoHashUtil calculateWidthDegrees:length] * [GeoHashUtil calculateHeightDegrees:length];
    double ratio = coverageAreaDegrees / areaDegrees;
    return [[Coverage alloc] initWithHashes:hashes ratio:[NSNumber numberWithDouble:ratio]];
}


// Add hash of the given length for a lat long point to a set
+ (void) addHash:(NSMutableSet *)hashes
        latitude:(double)latitude
       longitude:(double)longitude
      hashLength:(int)length
{
    // Changed by PKS: 2013/12/23 -- added to180() normalization for longitude
    [hashes addObject:[GeoHash hashForLatitude:latitude longitude:[self to180:longitude] length:length]];
}

// Returns the height in degrees of the region represented by a geohash of length hashlength
+ (double) calculateHeightDegrees:(int)hashLength
{
    double a;
    if (hashLength % 2 == 0)
        a = 0;
    else
        a = -0.5;
    double result = 180/pow(2.0, 2.5 * hashLength + a);
    return result;
}

// Returns the width in degrees of the region represented by a geohash of length hashlength
+ (double) calculateWidthDegrees:(int)hashLength
{
    double a;
    if (hashLength % 2 == 0)
        a = -1;
    else
        a = -0.5;
    double result = 180/pow(2.0, 2.5 * hashLength + a);
    return result;
}


// Returns the maximum length of hash that covers the bounding box. If no hash can enclose
// the bounding box then 0 is returned.
+ (int) hashLengthToCoverBoundingBoxWithTopLeftLat: (double)topLeftLat
                                        topLeftLon: (double)topLeftLon
                                    bottomRightLat: (double)bottomRightLat
                                    bottomRightLon: (double)bottomRightLon
{
    for (int i = MAX_HASH_LENGTH; i >= 1; i--) {
        NSString *hash = [GeoHash hashForLatitude:topLeftLat longitude:topLeftLon length:i];
        if ([GeoHashUtil hashContains:hash latitude:bottomRightLat longitude:bottomRightLon])
            return i;
    }
    return 0;
}
            
            
// Returns true if and only if the bounding box corresponding to the hash contains the
// given lat and long.
+ (Boolean) hashContains:(NSString *)hash
                latitude:(double)lat
               longitude:(double)lon
{
    LatLong *centre = [GeoHashUtil decodeHash:hash];
    return (fabs([centre latitude] - lat) <= [GeoHashUtil calculateHeightDegrees:hash.length] / 2) &&
        (fabs([GeoHashUtil to180:[centre longitude]] - lon) <= [GeoHashUtil calculateWidthDegrees:hash.length] / 2);
}


// Return the center lat long of a geohash
+ (LatLong *) decodeHash: (NSString *)hash {
    GHArea *latlongBox = [GeoHash areaForHash:hash];
    double centerlat = ([latlongBox latitude].max.doubleValue - [latlongBox latitude].min.doubleValue) / 2.0;
    double centerlon = ([latlongBox longitude].max.doubleValue - [latlongBox longitude].min.doubleValue) / 2.0;
    return [[LatLong alloc]initWithLatitude:centerlat longitude:centerlon];
}


+ (double)longitudeDiff:(double)lng1
             longitude2:(double)lng2
{
    double a = [GeoHashUtil to180:lng1];
    double b = [GeoHashUtil to180:lng2];
    if (a < b )
        return a - b + 360;
    else
        return a - b;
}


+ (double)to180:(double)d
{
    if (d < 0.) {
        return -[GeoHashUtil to180:(fabs(d))];
    } else {
        if (d > 180) {
            long n = round(floor((d + 180) / 360.0));
            return d - n * 360;
        } else
            return d;
    }
}


@end
