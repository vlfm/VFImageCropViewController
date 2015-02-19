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

#import "VFImageCropView.h"
#import "VFAspectRatio.h"
#import "VFCropAreaView.h"
#import "VFEdgeInsetsGenerator.h"

@interface VFImageCropView () <VFInteractiveFrameViewDelegate>

@end

@implementation VFImageCropView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    VFCropAreaView *_cropAreaView;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    _image = image;
    return self;
}

- (CGRect)cropRect {
    CGRect cropRect;
    CGRect cropAreaFrame = _cropAreaView.frame;
    
    UIView *zoomingView = [_scrollView.delegate viewForZoomingInScrollView:_scrollView];
    cropRect.origin = [self convertPoint:cropAreaFrame.origin toView:zoomingView];
    
    CGFloat zoomScale = _scrollView.zoomScale;
    cropRect.size.width = CGRectGetWidth(cropAreaFrame) / zoomScale;
    cropRect.size.height = CGRectGetHeight(cropAreaFrame) / zoomScale;
    
    return cropRect;
}

- (void)setAspectRatio:(VFAspectRatio *)aspectRatio {
    _aspectRatio = aspectRatio;
    _cropAreaView.aspectRatio = aspectRatio;
        
    [self setNeedsLayout];
        
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)setCropAreaMargins:(id<VFEdgeInsetsGenerator>)cropAreaMargins {
    _cropAreaMargins = cropAreaMargins;
    [self setNeedsLayout];
}

- (void)loadView {
    {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.maximumZoomScale = 4.0;
        _scrollView.clipsToBounds = NO;
        
        [_scrollView addSubview:_imageView];
        [self addSubview:_scrollView];
    }
    
    {
        _cropAreaView = [VFCropAreaView new];
        _cropAreaView.aspectRatio = _aspectRatio;
        _cropAreaView.delegate = self;
        [self addSubview:_cropAreaView];
    }
    
    self.backgroundColor = [UIColor blackColor];
}

#pragma mark layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.contentSize = _imageView.frame.size;
    _cropAreaView.insetsInSuperView = [_cropAreaMargins edgeInsetsWithBounds:self.bounds.size];
    
    CGRect rect = [self cropAreaRect];
    _cropAreaView.frame = rect;
    _scrollView.frame = rect;
    
    CGFloat minimumZoomScale =  CGRectGetWidth(rect) / _imageView.image.size.width;
    _scrollView.minimumZoomScale = minimumZoomScale;
    _scrollView.zoomScale = minimumZoomScale;
    
    _scrollView.contentOffset = [self scrollViewContentOffsetForZoomingViewCenter];
}

#pragma mark hit test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint p = [self convertPoint:point toView:_cropAreaView];
    if ([_cropAreaView hitTest:p withEvent:event] != nil) {
        return _cropAreaView;
    }
    
    p = [self convertPoint:point toView:_scrollView];
    if ([_scrollView hitTest:p withEvent:event] != nil) {
        return _scrollView;
    }
    
    UIView *zoomingView = [_scrollView.delegate viewForZoomingInScrollView:_scrollView];
    
    p = [self convertPoint:point toView:zoomingView];
    CGPoint scaledPoint = CGPointMake(p.x * _scrollView.zoomScale, p.y * _scrollView.zoomScale);
    if (CGRectContainsPoint(zoomingView.frame, scaledPoint)) {
        return _scrollView;
    }
    
    return nil;
}

#pragma mark grid

- (void)showCropAreaGrid {
    _cropAreaView.gridOn = YES;
}

- (void)hideCropAreaGrid {
    [_cropAreaView setGridOn:NO delay:0.15];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView: (UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self showCropAreaGrid];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    scrollView.contentInset = [self scrollViewContentInset];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self hideCropAreaGrid];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self showCropAreaGrid];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self hideCropAreaGrid];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self hideCropAreaGrid];
}

#pragma mark VFInteractiveFrameViewDelegate

- (void)interactiveFrameView:(VFInteractiveFrameView *)interactiveFrameView interactionHappensNowDidChange:(BOOL)value {
    if (value) {
        _cropAreaView.minimumSize = [self minimumCropAreaSize];
        [self showCropAreaGrid];
    }
    
    if (value == NO) {
        [self animateZoomToCropRectWithCompletion:^(BOOL finished) {
            [self hideCropAreaGrid];
        }];
    }
}

#pragma mark crop area

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

- (CGSize)minimumCropAreaSize {
    CGFloat scale = _scrollView.maximumZoomScale / _scrollView.zoomScale;
    CGSize size = _cropAreaView.maximumAvailableFrame.size;
    return CGSizeMake(size.width / scale, size.height / scale);
}

#pragma mark scroll view inset and offset

- (UIEdgeInsets)scrollViewContentInset {
    UIView *zoomingView = [_scrollView.delegate viewForZoomingInScrollView:_scrollView];
    
    CGFloat dw = CGRectGetWidth(_scrollView.frame) - CGRectGetWidth(zoomingView.frame);
    CGFloat dh = CGRectGetHeight(_scrollView.frame) - CGRectGetHeight(zoomingView.frame);
    
    CGFloat leftRight = MAX(0, dw / 2);
    CGFloat topBottom = MAX(0, dh / 2);
    
    return UIEdgeInsetsMake(topBottom, leftRight, topBottom, leftRight);
}

- (CGPoint)scrollViewContentOffsetForZoomingViewCenter {
    UIView *zoomingView = [_scrollView.delegate viewForZoomingInScrollView:_scrollView];
    
    CGFloat dw = MAX(0, (CGRectGetWidth(zoomingView.frame) - CGRectGetWidth(_scrollView.frame)));
    CGFloat dh = MAX(0, (CGRectGetHeight(zoomingView.frame) - CGRectGetHeight(_scrollView.frame)));
    
    UIEdgeInsets contentInset = [self scrollViewContentInset];
    return CGPointMake(-contentInset.left + dw / 2, -contentInset.top + dh / 2);
}

#pragma mark zoom to rect

- (void)animateZoomToCropRectWithCompletion:(void(^)(BOOL finished))completion {
    _cropAreaView.minimumSize = CGSizeZero;
    
    [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect rect = [self cropRect];
        [_scrollView zoomToRect:rect animated:NO];
        _cropAreaView.frame = [self cropAreaRect];
    } completion:completion];
}

@end
