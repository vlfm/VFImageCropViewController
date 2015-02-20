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

#import <UIKit/UIKit.h>

@interface VFAspectRatio : NSObject

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height;

- (CGSize)aspectSizeThatFitsInside:(CGSize)size;

- (CGSize)aspectSizeThatFits:(CGSize)size translationPoint:(CGPoint)point;

- (CGSize)aspectSizeWithFixedWidthThatFits:(CGSize)size;
- (CGSize)aspectSizeWithFixedHeightThatFits:(CGSize)size;

@end

VFAspectRatio * VFAspectRatioMake(NSInteger width, NSInteger height);