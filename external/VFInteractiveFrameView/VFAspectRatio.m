/*
 
 Copyright 2014 Valery Fomenko
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "VFAspectRatio.h"

CGFloat floorPoint(CGFloat value);

@implementation VFAspectRatio

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height {
    self = [super init];
    _width = width;
    _height = height;
    return self;
}

- (CGSize)aspectSizeThatFitsInside:(CGSize)size {
    CGFloat w = 0;
    CGFloat h = 0;
    
    if (_width == _height) {
        w = MIN(size.width, size.height);
        h = w;
    } else if (_width > _height) {
        w = size.width;
        h = (w / _width) * _height;
    } else {
        h = size.height;
        w = (h / _height) * _width;
    }
    
    CGFloat wOverhead = MAX(1, w / size.width);
    CGFloat hOverhead = MAX(1, h / size.height);
    
    CGFloat overhead = MAX(wOverhead, hOverhead);
    
    return CGSizeMake(floorPoint(w / overhead),
                      floorPoint(h / overhead));
}

- (CGSize)aspectSizeThatFits:(CGSize)size translationPoint:(CGPoint)point {
    if (fabs(point.x) > fabs(point.y)) {
        return [self aspectSizeWithFixedWidthThatFits:size];
    } else {
        return [self aspectSizeWithFixedHeightThatFits:size];
    }
}

- (CGSize)aspectSizeWithFixedWidthThatFits:(CGSize)size {
    CGFloat w = size.width;
    CGFloat h = (w / _width) * _height;
    return CGSizeMake(floorPoint(w), floorPoint(h));
}

- (CGSize)aspectSizeWithFixedHeightThatFits:(CGSize)size {
    CGFloat h = size.height;
    CGFloat w = (h / _height) * _width;
    return CGSizeMake(floorPoint(w), floorPoint(h));
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d:%d", _width, _height];
}

@end

VFAspectRatio * VFAspectRatioMake(NSInteger width, NSInteger height) {
    return [[VFAspectRatio alloc] initWithWidth:width height:height];
}

CGFloat floorPoint(CGFloat value) {
    return floor(value * 2) / 2;
}