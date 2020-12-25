/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNSVGDefsManager.h"
#import "RNSVGDefs.h"

#ifdef TARGET_OS_OSX
#define PLATFORM_VIEW NSView
#else
#define PLATFORM_VIEW UIView
#endif

@implementation RNSVGDefsManager

RCT_EXPORT_MODULE()

- (RNSVGDefs *)node
{
  return [RNSVGDefs new];
}

- (PLATFORM_VIEW *)view
{
    return [self node];
}

@end
