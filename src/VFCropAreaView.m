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
    self.userInteractionEnabled = NO;
    
    return  self;
}

#pragma mark draw

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawBorderWithLineWidth:1.0 color:[UIColor whiteColor]];
    [self drawGridWithDimensionSize:4 insideBorderWithLineWidth:1.0 color:[UIColor whiteColor]];
}

- (void)drawBorderWithLineWidth:(CGFloat)borderLineWidth color:(UIColor *)color {
    [self drawWithContext:^(CGContextRef context) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat borderLineWidthInPixels = borderLineWidth * scale;
        
        CGContextSetLineWidth(context, borderLineWidthInPixels);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
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
        
    CGRect lineRect = CGRectMake(startPoint.x, startPoint.y, lineSize.width, lineSize.height);
        
    CGContextFillRect(context, lineRect);
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
