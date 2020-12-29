/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */
#import "RNSVGDefs.h"

#if TARGET_OS_OSX == 1

#define PLATFORM_VIEW NSView
#define PLATFORM_EVENT NSEvent

#else

#define PLATFORM_VIEW UIView
#define PLATFORM_EVENT UIEvent

#endif

@class RNSVGNode;

@implementation RNSVGDefs

- (void)renderTo:(CGContextRef)context
{
    // Defs do not render
}

- (void)parseReference
{
    self.dirty = false;
    [self traverseSubviews:^(RNSVGNode *node) {
        if ([node isKindOfClass:[RNSVGNode class]]) {
            [node parseReference];
        }
        return YES;
    }];
}

- (PLATFORM_VIEW *)hitTest:(CGPoint)point withEvent:(PLATFORM_EVENT *)event
{
    return nil;
}

@end

