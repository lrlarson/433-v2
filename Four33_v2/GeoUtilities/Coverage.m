//
//  Coverage.m
//  FourThirtyThree
//
//  Created by Phil Stone on 12/13/13.
//  Copyright (c) 2013 John Cage Trust. All rights reserved.
//

#import "Coverage.h"

@implementation Coverage

@synthesize hashes;
/**
 * How well the coverage is covered by the hashes. Will be >=1. Closer to 1
 * the close the coverage is to the region in question.
 */
@synthesize ratio;


- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:@"Coverage ------\n ratio: %3.5f", [ratio doubleValue]];
    [desc appendString:@"\nGeohashes:"];
    for (id element in hashes) {
    [desc appendString:@"\n   "];
        [desc appendString:element];
    }
    return [NSString stringWithString:desc];
}

+ (id)coverageWithHashes:(NSSet *)_hashes
               ratio:(NSNumber *)_ratio
{
    return [[Coverage alloc] initWithHashes:_hashes
                                      ratio:_ratio];
}

- (id)initWithHashes:(NSSet *)_hashes
               ratio:(NSNumber *)_ratio
{
    if ((self = [super init]) != nil) {
        hashes = _hashes;
        ratio = _ratio;
    }
    return self;
}

@end
