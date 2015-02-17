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

#import "VFCropOverlayView.h"

#import "VFAspectRatio.h"
#import "VFCropAreaView.h"
#import "VFEdgeInsetsGenerator.h"

@implementation VFCropOverlayView {
    VFCropAreaView *_cropAreaView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _cropAreaView = [VFCropAreaView new];
    [self addSubview:_cropAreaView];
    
    return  self;
}

- (void)setAspectRatio:(VFAspectRatio *)aspectRatio {
    _aspectRatio = aspectRatio;
    _cropAreaView.aspectRatio = aspectRatio;
    
    [self setNeedsLayout];
}

- (void)setCropAreaMargins:(id<VFEdgeInsetsGenerator>)cropAreaMargins {
    _cropAreaMargins = cropAreaMargins;
    [self setNeedsLayout];
}

- (UIEdgeInsets)contentInsetsForImageScrollView:(UIScrollView *)scrollView {
    CGFloat w = MAX(0, (CGRectGetWidth([self cropAreaRect]) - scrollView.contentSize.width) / 2);
    CGFloat h = MAX(0, (CGRectGetHeight([self cropAreaRect]) - scrollView.contentSize.height) / 2);
    
    CGFloat top = CGRectGetMinY([self cropAreaRect]) + h;
    CGFloat leftRight = (CGRectGetWidth(scrollView.frame) - CGRectGetWidth([self cropAreaRect])) / 2.0 + w;
    CGFloat bottom = CGRectGetHeight(scrollView.frame) - CGRectGetMaxY([self cropAreaRect]) + h;
    
    return UIEdgeInsetsMake(top, leftRight, bottom, leftRight);
}

- (CGPoint)centerContentOffsetForImageScrollView:(UIScrollView *)scrollView {
    CGFloat w = MAX(0, (scrollView.contentSize.width - CGRectGetWidth([self cropAreaRect])) / 2);
    CGFloat h = MAX(0, (scrollView.contentSize.height - CGRectGetHeight([self cropAreaRect])) / 2);
    
    return CGPointMake(-scrollView.contentInset.left + w, -scrollView.contentInset.top + h);
}

- (CGRect)cropRectWithImageScrollView:(UIScrollView *)scrollView {
    CGFloat zoomScale = scrollView.zoomScale;
    
    CGRect cropRect;
    
    CGFloat dx = CGRectGetMinX([self cropAreaRect]);
    CGFloat dy = CGRectGetMinY([self cropAreaRect]);
    
    cropRect.origin.x = ([scrollView contentOffset].x + dx) / zoomScale;
    cropRect.origin.y = ([scrollView contentOffset].y + dy) / zoomScale;
    
    cropRect.size.width = CGRectGetWidth([self cropAreaRect]) / zoomScale;
    cropRect.size.height = CGRectGetHeight([self cropAreaRect]) / zoomScale;
    
    return cropRect;
}

- (CGFloat)minimumZoomScaleWithImage:(UIImage *)image {
    return CGRectGetWidth([self cropAreaRect]) / image.size.width;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint convertedPoint = [self convertPoint:point toView:_cropAreaView];
    return [_cropAreaView hitTest:convertedPoint withEvent:event];
}

#pragma mark layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_cropAreaView.interactionHappensNow) {
        return;
    }
    
    UIEdgeInsets cropAreaMargins = UIEdgeInsetsZero;
    if (self.cropAreaMargins) {
        cropAreaMargins = [self.cropAreaMargins edgeInsetsWithBounds:self.bounds.size];
    }
    
    _cropAreaView.insetsInSuperView = cropAreaMargins;
    _cropAreaView.frame = [self cropAreaRect];
}

# pragma mark private

- (CGRect)cropAreaRect {
    CGRect maximumAvailableRect = _cropAreaView.maximumAvailableFrame;
    CGSize areaSize = _cropAreaView.maximumAllowedFrame.size;
    
    CGFloat dx = (CGRectGetWidth(maximumAvailableRect) - areaSize.width) / 2;
    CGFloat dy = (CGRectGetHeight(maximumAvailableRect) - areaSize.height) / 2;
    
    return CGRectMake(CGRectGetMinX(maximumAvailableRect) + dx,
                      CGRectGetMinY(maximumAvailableRect) + dy,
                      areaSize.width,
                      areaSize.height);
}

@end