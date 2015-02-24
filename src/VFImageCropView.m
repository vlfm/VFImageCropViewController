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
#import "VFImageCropOverlayController.h"

void doAfterDelay(NSTimeInterval delay, void(^task)());

@interface VFImageCropView () <VFInteractiveFrameViewDelegate>

@end

@implementation VFImageCropView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    VFCropAreaView *_cropAreaView;
    VFImageCropOverlayController *_cropOverlayController;
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

- (void)setAspectRatioFixed:(BOOL)aspectRatioFixed {
    _aspectRatioFixed = aspectRatioFixed;
    _cropAreaView.aspectRatioFixed = aspectRatioFixed;
}

- (void)setCropAreaMargins:(id<VFEdgeInsetsGenerator>)cropAreaMargins {
    _cropAreaMargins = cropAreaMargins;
    [self setNeedsLayout];
}

- (void)loadView {
    _imageView = [[UIImageView alloc] initWithImage:_image];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.clipsToBounds = NO;
        
    [_scrollView addSubview:_imageView];
    [self addSubview:_scrollView];
    
    _cropAreaView = [VFCropAreaView new];
    _cropAreaView.aspectRatio = _aspectRatio;
    _cropAreaView.aspectRatioFixed = _aspectRatioFixed;
    _cropAreaView.delegate = self;
    [self addSubview:_cropAreaView];
    
    _cropOverlayController = [[VFImageCropOverlayController alloc] initWithTargetView:self];
    _cropOverlayController.blurEnabled = YES;
    
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
    
    _cropOverlayController.cropAreaRect = rect;
    
    CGFloat minimumZoomScale =  MAX(CGRectGetWidth(rect) / _imageView.image.size.width,
                                    CGRectGetHeight(rect) / _imageView.image.size.height);
    _scrollView.minimumZoomScale = minimumZoomScale;
    _scrollView.zoomScale = minimumZoomScale;
    _scrollView.maximumZoomScale = minimumZoomScale * 10;
    
    _scrollView.contentOffset = [self scrollViewContentOffsetForZoomingViewCenter];
    _scrollView.contentInset = [self scrollViewContentInset];
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

#pragma mark interaction dependent adjustments

- (void)updateDisplayPropertiesWithUserInteractionHappensNow:(BOOL)userInteractionHappensNow {
    if (userInteractionHappensNow) {
        _cropAreaView.gridOn = YES;
        _cropOverlayController.blurEnabled = NO;
    } else {
        doAfterDelay(0.15, ^{
            _cropAreaView.gridOn = NO;
            _cropOverlayController.blurEnabled = YES;
        });
    }
    
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView: (UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self updateDisplayPropertiesWithUserInteractionHappensNow:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    scrollView.contentInset = [self scrollViewContentInset];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self updateDisplayPropertiesWithUserInteractionHappensNow:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self updateDisplayPropertiesWithUserInteractionHappensNow:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateDisplayPropertiesWithUserInteractionHappensNow:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateDisplayPropertiesWithUserInteractionHappensNow:NO];
}

#pragma mark VFInteractiveFrameViewDelegate

- (void)interactiveFrameViewDidBeginInteraction:(VFInteractiveFrameView *)interactiveFrameView {
    _cropAreaView.minimumSize = [self minimumCropAreaSize];
    [self updateDisplayPropertiesWithUserInteractionHappensNow:YES];
}

- (void)interactiveFrameView:(VFInteractiveFrameView *)interactiveFrameView didChangeFrame:(CGRect)frame {
    _cropOverlayController.cropAreaRect = frame;
}

- (void)interactiveFrameView:(VFInteractiveFrameView *)interactiveFrameView
  didEndInteractionWithFrame:(CGRect)frame
                 aspectRatio:(VFAspectRatio *)aspectRatio {
    
    [self animateZoomToCropRectWithCompletion:^(BOOL finished) {
        [self updateDisplayPropertiesWithUserInteractionHappensNow:NO];
    }];
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
    CGSize size = _cropAreaView.maximumAllowedFrame.size;
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
    
    CGRect cropRect = [self cropRect];
    CGRect cropAreaRect = [self cropAreaRect];
    
    [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _scrollView.frame = cropAreaRect;
        _scrollView.contentInset = [self scrollViewContentInset];
        [_scrollView zoomToRect:cropRect animated:NO];
        _cropAreaView.frame = cropAreaRect;
        _cropOverlayController.cropAreaRect = cropAreaRect;
    } completion:completion];
}

@end

void doAfterDelay(NSTimeInterval delay, void(^task)()) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        task();
    });
}
