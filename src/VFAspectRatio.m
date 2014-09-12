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

@implementation VFAspectRatio

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height {
    self = [super init];
    _width = width;
    _height = height;
    return self;
}

- (CGSize)aspectSizeThatFits:(CGSize)size padding:(CGFloat)padding {
    CGFloat w = 0;
    CGFloat h = 0;
    
    if (_width == _height) {
        w = MIN(size.width, size.height) - padding;
        h = w;
    } else if (_width > _height) {
        w = size.width - padding;
        h = (w / _width) * _height;
    } else {
        h = size.height - padding;
        w = (h / _height) * _width;
    }
    
    return CGSizeMake(w, h);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d:%d", _width, _height];
}

@end

VFAspectRatio * VFAspectRatioMake(NSInteger width, NSInteger height) {
    return [[VFAspectRatio alloc] initWithWidth:width height:height];
}