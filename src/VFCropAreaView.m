/*
 
 Copyright 2015 Valery Fomenko
 
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

#import "VFCropAreaView.h"

@implementation VFCropAreaView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    
    return  self;
}

- (void)setGridOn:(BOOL)gridOn {
    _gridOn = gridOn;
    [self setNeedsDisplay];
}

#pragma mark draw

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawBorderWithLineWidth:1.0 color:[UIColor whiteColor]];
    
    if (self.gridOn) {
        [self drawGridWithDimensionSize:3 insideBorderWithLineWidth:1.0 color:[UIColor whiteColor]];
    }
    
    if (!self.gridOn) {
        [self drawEdgesWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] size:CGSizeMake(10, 10)];
    }
}

- (void)drawBorderWithLineWidth:(CGFloat)borderLineWidth color:(UIColor *)color {
    [self drawWithContext:^(CGContextRef context) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat borderLineWidthInPixels = borderLineWidth * scale;
        
        CGContextSetLineWidth(context, borderLineWidthInPixels);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetAllowsAntialiasing(context, NO);
        CGContextStrokeRect(context, self.bounds);
    }];
}

- (void)drawGridWithDimensionSize:(NSInteger)gridDimensionSize insideBorderWithLineWidth:(CGFloat)borderLineWidth color:(UIColor *)color {
    [self drawWithContext:^(CGContextRef context) {
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        [self drawGridLinesWithContext:context gridDimensionSize:gridDimensionSize borderLineWidth:borderLineWidth drawLineBlock:^(NSInteger lineIndex,
                                                                                                                                   CGFloat startCoordinateOffset,
                                                                                                                                   CGSize gridCellSize,
                                                                                                                                   CGFloat borderLineWidth,
                                                                                                                                   CGFloat lineWidth) {
            [self drawGridHorizontalLineWithContext:context lineIndex:lineIndex startCoordinateOffset:startCoordinateOffset
                                       gridCellSize:gridCellSize borderLineWidth:borderLineWidth lineWidth:lineWidth];
        }];
        
        [self drawGridLinesWithContext:context gridDimensionSize:gridDimensionSize borderLineWidth:borderLineWidth drawLineBlock:^(NSInteger lineIndex,
                                                                                                                                   CGFloat startCoordinateOffset,
                                                                                                                                   CGSize gridCellSize,
                                                                                                                                   CGFloat borderLineWidth,
                                                                                                                                   CGFloat lineWidth) {
            [self drawGridVerticalLineWithContext:context lineIndex:lineIndex startCoordinateOffset:startCoordinateOffset
                                       gridCellSize:gridCellSize borderLineWidth:borderLineWidth lineWidth:lineWidth];
        }];
    }];
}

- (void)drawGridLinesWithContext:(CGContextRef)context gridDimensionSize:(NSInteger)gridDimensionSize
                 borderLineWidth:(CGFloat)borderLineWidth drawLineBlock:(void(^)(NSInteger lineIndex,
                                                                                 CGFloat startCoordinateoffset,
                                                                                 CGSize gridCellSize,
                                                                                 CGFloat borderLineWidth,
                                                                                 CGFloat lineWidth))drawLineBlock {
    
    CGFloat lineWidth = 0.5;
    CGSize gridCellSize = [self gridCellSizeWithDimensionSize:gridDimensionSize borderWithLineWidth:borderLineWidth lineWidth:lineWidth];
    
    CGFloat startCoordinateOffset = borderLineWidth;
    for (NSInteger i = 1; i < gridDimensionSize; i++) {
        drawLineBlock(i, startCoordinateOffset, gridCellSize, borderLineWidth, lineWidth);
        startCoordinateOffset += lineWidth;
    }
}

- (void)drawGridHorizontalLineWithContext:(CGContextRef)context lineIndex:(NSInteger)lineIndex
                    startCoordinateOffset:(CGFloat)startCoordinateOffset gridCellSize:(CGSize)gridCellSize
                          borderLineWidth:(CGFloat)borderLineWidth lineWidth:(CGFloat)lineWidth {
    
    CGPoint startPoint = CGPointMake(borderLineWidth, startCoordinateOffset + lineIndex * gridCellSize.height);
    CGPoint endPoint = CGPointMake(CGRectGetWidth(self.bounds) - borderLineWidth, startCoordinateOffset + lineIndex * gridCellSize.height);
    [self drawLineWithContext:context startPoint:startPoint endPoint:endPoint lineWidth:lineWidth];
}

- (void)drawGridVerticalLineWithContext:(CGContextRef)context lineIndex:(NSInteger)lineIndex
                  startCoordinateOffset:(CGFloat)startCoordinateOffset gridCellSize:(CGSize)gridCellSize
                        borderLineWidth:(CGFloat)borderLineWidth lineWidth:(CGFloat)lineWidth {
    
    CGPoint startPoint = CGPointMake(startCoordinateOffset + lineIndex * gridCellSize.width, borderLineWidth);
    CGPoint endPoint = CGPointMake(startCoordinateOffset + lineIndex * gridCellSize.width, CGRectGetHeight(self.bounds) - borderLineWidth);
    [self drawLineWithContext:context startPoint:startPoint endPoint:endPoint lineWidth:lineWidth];
}

- (void)drawLineWithContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineWidth:(CGFloat)lineWidth {
    CGSize lineSize = CGSizeZero;
        
    BOOL isHorizontalLine = (startPoint.y == endPoint.y);
    if (isHorizontalLine) {
        lineSize = CGSizeMake(endPoint.x - startPoint.x, lineWidth);
    }
        
    BOOL isVerticalLine = (startPoint.x == endPoint.x);
    if (isVerticalLine) {
        lineSize = CGSizeMake(lineWidth, endPoint.y - startPoint.y);
    }
        
    CGRect lineRect = CGRectMake(startPoint.x, startPoint.y,
                                 lineSize.width, lineSize.height);
        
    CGContextFillRect(context, lineRect);
}

- (void)drawEdgesWithColor:(UIColor *)color size:(CGSize)size {
    [self drawWithContext:^(CGContextRef context) {
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.7].CGColor);
        
        CGFloat w = size.width;
        CGFloat h = size.height;
        
        CGRect top = CGRectMake(CGRectGetWidth(self.bounds) / 2 - w / 2, 0, w, h);
        CGContextFillRect(context, top);
        
        CGRect left = CGRectMake(0, CGRectGetHeight(self.bounds) / 2 - h / 2, w, h);
        CGContextFillRect(context, left);
        
        CGRect bottom = CGRectMake(CGRectGetWidth(self.bounds) / 2 - w / 2, CGRectGetMaxY(self.bounds) - h, w, h);
        CGContextFillRect(context, bottom);
        
        CGRect right = CGRectMake(CGRectGetMaxX(self.bounds) - w, CGRectGetHeight(self.bounds) / 2 - h / 2, w, h);
        CGContextFillRect(context, right);
        
        CGRect topLeft = CGRectMake(0, 0, w, h);
        CGContextFillRect(context, topLeft);
        
        CGRect topRight = CGRectMake(CGRectGetMaxX(self.bounds) - w, 0, w, h);
        CGContextFillRect(context, topRight);
        
        CGRect bottomLeft = CGRectMake(0, CGRectGetMaxY(self.bounds) - h, w, h);
        CGContextFillRect(context, bottomLeft);
        
        CGRect bottomRight = CGRectMake(CGRectGetMaxX(self.bounds) - w, CGRectGetMaxY(self.bounds) - h, w, h);
        CGContextFillRect(context, bottomRight);
    }];
}

- (void)drawWithContext:(void(^)(CGContextRef context))drawBlock {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    drawBlock(context);
    CGContextRestoreGState(context);
}

- (CGSize)gridCellSizeWithDimensionSize:(NSInteger)gridDimensionSize borderWithLineWidth:(CGFloat)borderLineWidth lineWidth:(CGFloat)lineWidth {
    CGFloat lineCount = gridDimensionSize - 1;
    CGFloat borderAndLinesSpace = 2 * borderLineWidth - lineCount * lineWidth;
    CGFloat width = round((CGRectGetWidth(self.bounds) - borderAndLinesSpace) / gridDimensionSize);
    CGFloat height = round((CGRectGetHeight(self.bounds) - borderAndLinesSpace) / gridDimensionSize);
    return CGSizeMake(width, height);
}

@end