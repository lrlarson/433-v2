//
//  Coverage.h
//  FourThirtyThree
//
//  Created by Phil Stone on 12/13/13.
//  Copyright (c) 2013 John Cage Trust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coverage : NSObject {
    NSSet *hashes;
    NSNumber *ratio;
}
@property (readonly, strong) NSSet *hashes;
@property (readonly, strong) NSNumber *ratio;

+ (id)coverageWithHashes:(NSSet *)_hashes
                   ratio:(NSNumber *)_ratio;
- (id)initWithHashes:(NSSet *)_hashes
               ratio:(NSNumber *)_ratio;

@end
