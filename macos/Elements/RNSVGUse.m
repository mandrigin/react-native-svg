/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */
#import "RNSVGUse.h"
#import "RNSVGSymbol.h"
#import <React/RCTLog.h>

#ifdef TARGET_OS_OSX
#define PLATFORM_VIEW NSView
#define PLATFORM_EVENT NSEvent
#else
#define PLATFORM_VIEW UIView
#define PLATFORM_EVENT UIEvent
#endif

@implementation RNSVGUse

- (void)setHref:(NSString *)href
{
    if ([href isEqualToString:_href]) {
        return;
    }

    [self invalidate];
    _href = href;
}

- (void)setX:(RNSVGLength *)x
{
    if ([x isEqualTo:_x]) {
        return;
    }

    [self invalidate];
    _x = x;
}

- (void)setY:(RNSVGLength *)y
{
    if ([y isEqualTo:_y]) {
        return;
    }

    [self invalidate];
    _y = y;
}


- (void)setUsewidth:(RNSVGLength *)usewidth
{
    if ([usewidth isEqualTo:_usewidth]) {
        return;
    }

    [self invalidate];
    _usewidth = usewidth;
}

- (void)setUseheight:(RNSVGLength *)useheight
{
    if ([useheight isEqualTo:_useheight]) {
        return;
    }

    [self invalidate];
    _useheight = useheight;
}

- (void)renderLayerTo:(CGContextRef)context rect:(CGRect)rect
{
    CGContextTranslateCTM(context, [self relativeOnWidth:self.x], [self relativeOnHeight:self.y]);
    RNSVGNode* template = [self.svgView getDefinedTemplate:self.href];
    if (template) {
        [self beginTransparencyLayer:context];
        [self clip:context];

        if ([template isKindOfClass:[RNSVGRenderable class]]) {
            [(RNSVGRenderable*)template mergeProperties:self];
        }

        if ([template class] == [RNSVGSymbol class]) {
            RNSVGSymbol *symbol = (RNSVGSymbol*)template;
            [symbol renderSymbolTo:context width:[self relativeOnWidth:self.usewidth] height:[self relativeOnHeight:self.useheight]];
        } else {
            [template renderTo:context rect:rect];
        }

        if ([template isKindOfClass:[RNSVGRenderable class]]) {
            [(RNSVGRenderable*)template resetProperties];
        }

        [self endTransparencyLayer:context];
    } else if (self.href) {
        // TODO: calling yellow box here
        RCTLogWarn(@"`Use` element expected a pre-defined svg template as `href` prop, template named: %@ is not defined.", self.href);
        return;
    } else {
        return;
    }
    CGRect bounds = template.clientRect;
    self.clientRect = bounds;
    
    CGAffineTransform current = CGContextGetCTM(context);
    CGAffineTransform svgToClientTransform = CGAffineTransformConcat(current, self.svgView.invInitialCTM);
    
    self.ctm = svgToClientTransform;
    self.screenCTM = current;
    
    CGAffineTransform transform = CGAffineTransformConcat(self.matrix, self.transforms);
    CGPoint mid = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint center = CGPointApplyAffineTransform(mid, transform);

    self.bounds = bounds;
    if (!isnan(center.x) && !isnan(center.y)) {
#ifndef TARGET_OS_OSX
        self.center = center;
#else
        self.frame = CGRectMake(center.x - (self.bounds.size.width / 2.0),
                                center.y - (self.bounds.size.height / 2.0),
                                self.frame.size.height,
                                self.frame.size.width);
#endif
    }
    self.frame = bounds;
}

- (PLATFORM_VIEW *)hitTest:(CGPoint)point withEvent:(PLATFORM_EVENT *)event {
    CGPoint transformed = CGPointApplyAffineTransform(point, self.invmatrix);
    transformed =  CGPointApplyAffineTransform(transformed, self.invTransform);
    RNSVGNode const* template = [self.svgView getDefinedTemplate:self.href];
    if (event) {
        self.active = NO;
    } else if (self.active) {
        return self;
    }
#ifndef TARGET_OS_OSX
    PLATFORM_VIEW const* hitChild = [template hitTest:transformed withEvent:event];
    if (hitChild) {
        self.active = YES;
        return self;
    }
#endif
    return nil;
}

- (CGPathRef)getPath: (CGContextRef)context
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation([self relativeOnWidth:self.x], [self relativeOnHeight:self.y]);
    RNSVGNode const* template = [self.svgView getDefinedTemplate:self.href];
    if (!template) {
        return nil;
    }
    CGPathRef path = [template getPath:context];
    return CGPathCreateCopyByTransformingPath(path, &transform);
}

@end

