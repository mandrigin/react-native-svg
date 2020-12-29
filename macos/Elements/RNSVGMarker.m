/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */
#import "RNSVGMarker.h"
#import "RNSVGPainter.h"
#import "RNSVGBrushType.h"
#import "RNSVGNode.h"
#import "RNSVGViewBox.h"

#if TARGET_OS_OSX == 1
#define PLATFORM_VIEW NSView
#define PLATFORM_COLOR NSColor
#define PLATFORM_EVENT NSEvent
#else
#define PLATFORM_VIEW UIView
#define PLATFORM_COLOR UIColor
#define PLATFORM_EVENT UIEvent
#endif

@implementation RNSVGMarker

- (PLATFORM_VIEW *)hitTest:(CGPoint)point withEvent:(PLATFORM_EVENT *)event
{
    return nil;
}

- (void)parseReference
{
    self.dirty = false;
    [self.svgView defineMarker:self markerName:self.name];
    [self traverseSubviews:^(RNSVGNode *node) {
        if ([node isKindOfClass:[RNSVGNode class]]) {
            [node parseReference];
        }
        return YES;
    }];
}

- (void)setX:(RNSVGLength *)refX
{
    if ([refX isEqualTo:_refX]) {
        return;
    }

    _refX = refX;
    [self invalidate];
}

- (void)setY:(RNSVGLength *)refY
{
    if ([refY isEqualTo:_refY]) {
        return;
    }

    _refY = refY;
    [self invalidate];
}

- (void)setMarkerWidth:(RNSVGLength *)markerWidth
{
    if ([markerWidth isEqualTo:_markerWidth]) {
        return;
    }

    _markerWidth = markerWidth;
    [self invalidate];
}

- (void)setMarkerHeight:(RNSVGLength *)markerHeight
{
    if ([markerHeight isEqualTo:_markerHeight]) {
        return;
    }

    _markerHeight = markerHeight;
    [self invalidate];
}

- (void)setMarkerUnits:(NSString *)markerUnits
{
    if ([_markerUnits isEqualToString:markerUnits]) {
        return;
    }

    _markerUnits = markerUnits;
    [self invalidate];
}

- (void)setOrient:(NSString *)orient
{
    if ([orient isEqualToString:_orient]) {
        return;
    }

    [self invalidate];
    _orient = orient;
}

- (void)setMinX:(CGFloat)minX
{
    if (minX == _minX) {
        return;
    }

    [self invalidate];
    _minX = minX;
}

- (void)setMinY:(CGFloat)minY
{
    if (minY == _minY) {
        return;
    }

    [self invalidate];
    _minY = minY;
}

- (void)setVbWidth:(CGFloat)vbWidth
{
    if (vbWidth == _vbWidth) {
        return;
    }

    [self invalidate];
    _vbWidth = vbWidth;
}

- (void)setVbHeight:(CGFloat)vbHeight
{
    if (_vbHeight == vbHeight) {
        return;
    }

    [self invalidate];
    _vbHeight = vbHeight;
}

- (void)setAlign:(NSString *)align
{
    if ([align isEqualToString:_align]) {
        return;
    }

    [self invalidate];
    _align = align;
}

- (void)setMeetOrSlice:(RNSVGVBMOS)meetOrSlice
{
    if (meetOrSlice == _meetOrSlice) {
        return;
    }

    [self invalidate];
    _meetOrSlice = meetOrSlice;
}

static CGFloat RNSVG_degToRad = (CGFloat)M_PI / 180;

double deg2rad(CGFloat deg) {
    return deg * RNSVG_degToRad;
}

- (void)renderMarker:(CGContextRef)context rect:(CGRect)rect position:(RNSVGMarkerPosition*)position strokeWidth:(CGFloat)strokeWidth
{
    CGContextSaveGState(context);

    CGPoint origin = [position origin];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(origin.x, origin.y);

    float markerAngle = [@"auto" isEqualToString:_orient] ? -1 : [_orient doubleValue];
    float angle = 180 + (markerAngle == -1 ? [position angle] : markerAngle);
    float rad = deg2rad(angle);
    transform = CGAffineTransformRotate(transform, rad);

    bool useStrokeWidth = [@"strokeWidth" isEqualToString:_markerUnits];
    if (useStrokeWidth) {
        transform = CGAffineTransformScale(transform, strokeWidth, strokeWidth);
    }

    CGFloat width = [self relativeOnWidth:self.markerWidth];
    CGFloat height = [self relativeOnHeight:self.markerHeight];
    CGRect eRect = CGRectMake(0, 0, width, height);
    if (self.align) {
        CGAffineTransform viewBoxTransform = [RNSVGViewBox getTransform:CGRectMake(self.minX, self.minY, self.vbWidth, self.vbHeight)
                                                                  eRect:eRect
                                                                  align:self.align
                                                            meetOrSlice:self.meetOrSlice];
        transform = CGAffineTransformScale(transform, viewBoxTransform.a, viewBoxTransform.d);
    }

    CGFloat x = [self relativeOnWidth:self.refX];
    CGFloat y = [self relativeOnHeight:self.refY];
    transform = CGAffineTransformTranslate(transform,  -x, -y);
#if TARGET_OS_OSX == 1
    self.layer.affineTransform = transform;
#else
    self.transform = transform;
#endif
    CGContextConcatCTM(context, transform);

    [self renderGroupTo:context rect:eRect];

    CGContextRestoreGState(context);
}

@end

