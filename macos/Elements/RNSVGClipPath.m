/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNSVGClipPath.h"

#if TARGET_OS_OSX == 1
#define PLATFORM_VIEW NSView
#else
#define PLATFORM_VIEW UIView
#endif

@implementation RNSVGClipPath

- (void)parseReference
{
    self.dirty = false;
    [self.svgView defineClipPath:self clipPathName:self.name];
}


- (BOOL)isSimpleClipPath
{
    NSArray<PLATFORM_VIEW*> *children = self.subviews;
    if (children.count == 1) {
        PLATFORM_VIEW* child = children[0];
        if ([child class] != [RNSVGGroup class]) {
            return true;
        }
    }
    return false;
}

@end
