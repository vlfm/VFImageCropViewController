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

#import "VFCropAreaView.h"
#import "VFImageCropView.h"
#import "VFAspectRatio.h"

@implementation VFImageCropView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    VFCropAreaView *_cropAreaView;
    UIToolbar *_toolbar;
    
    BOOL _needsUpdateZoomScaleNextLayout;
}

- (instancetype)initWithImage:(UIImage *)image delegate:(id<VFImageCropViewDelegate>)delegate {
    self = [super init];
    _image = image;
    _delegate = delegate;
    return self;
}

- (void)setCropFramePadding:(CGFloat)cropFramePadding {
    _cropFramePadding = cropFramePadding;
    [self setNeedsLayout];
}

- (CGRect)cropRect {
    float zoomScale = 1.0 / [_scrollView zoomScale];
    
    CGRect cropRect;
    
    CGFloat dx = CGRectGetMinX(_cropAreaView.cropAreaRect);
    CGFloat dy = CGRectGetMinY(_cropAreaView.cropAreaRect);
    
    cropRect.origin.x = ([_scrollView contentOffset].x + dx) * zoomScale;
    cropRect.origin.y = ([_scrollView contentOffset].y + dy) * zoomScale;
    
    cropRect.size.width = CGRectGetWidth(_cropAreaView.cropAreaRect) * zoomScale;
    cropRect.size.height = CGRectGetHeight(_cropAreaView.cropAreaRect) * zoomScale;
    
    return cropRect;
}

- (void)setAspectRatio:(VFAspectRatio *)aspectRatio {
    _aspectRatio = aspectRatio;
    
    BOOL isLoaded = (_toolbar != nil);
    
    if (isLoaded) {
        _toolbar.items = [self toolbarApectRatioItems];
        
        [self setNeedsLayout];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void)loadView {
    
    {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.maximumZoomScale = 2.0;
        
        [_scrollView addSubview:_imageView];
        [self addSubview:_scrollView];
    }
    
    {
        _cropAreaView = [VFCropAreaView new];
        [self addSubview:_cropAreaView];
    }
    
    {
        _toolbar = [UIToolbar new];
        _toolbar.barStyle = UIBarStyleBlack;
        _toolbar.items = [self toolbarApectRatioItems];
        
        [self addSubview:_toolbar];
    }
    
    self.backgroundColor = [UIColor blackColor];
    
    _needsUpdateZoomScaleNextLayout = YES;
}

- (NSArray *)toolbarApectRatioItems {
    return @[
             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
             
             [[UIBarButtonItem alloc] initWithTitle:_aspectRatio.description
                                              style:UIBarButtonItemStylePlain
                                             target:self action:@selector(tapAspectRatioOption:)],
             
             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
             ];
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    {
        _scrollView.frame = self.bounds;
    }
    
    {
        [_toolbar sizeToFit];
        
        CGRect frame = _toolbar.frame;
        frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame);
        _toolbar.frame = frame;
    }
    
    {
        CGRect cropAvailableRect = [self availableFrameToPlaceCropArea];
        
        CGSize areaSize = [_aspectRatio aspectSizeThatFits:cropAvailableRect.size
                                                   padding:_cropFramePadding];
        
        
        _cropAreaView.frame = CGRectMake((CGRectGetWidth(cropAvailableRect) - areaSize.width) / 2,
                                         _topLayoutGuideLength + (CGRectGetHeight(cropAvailableRect) - areaSize.height) / 2,
                                         areaSize.width,
                                         areaSize.height);
        
        CGFloat minimumZoomScale = CGRectGetWidth(_cropAreaView.cropAreaRect) / _image.size.width;
        
        _scrollView.contentSize = _imageView.frame.size;
        _scrollView.minimumZoomScale = minimumZoomScale;
        _scrollView.contentInset = [self calculateContentInset];
        
        if (_needsUpdateZoomScaleNextLayout) {
            _scrollView.zoomScale = minimumZoomScale;
            _needsUpdateZoomScaleNextLayout = NO;
        }
        
        if (_scrollView.zoomScale < minimumZoomScale) {
            _scrollView.zoomScale = minimumZoomScale;
        }
        
        _scrollView.contentOffset = [self calculateCenterContentOffsetWithContentInset:_scrollView.contentInset];
    }
}

- (UIEdgeInsets)calculateContentInset {
    CGFloat w = MAX(0, (CGRectGetWidth(_cropAreaView.cropAreaRect) - _scrollView.contentSize.width) / 2);
    CGFloat h = MAX(0, (CGRectGetHeight(_cropAreaView.cropAreaRect) - _scrollView.contentSize.height) / 2);
    
    CGFloat top = CGRectGetMinY(_cropAreaView.frame) + h;
    CGFloat leftRight = (CGRectGetWidth(self.frame) - CGRectGetWidth(_cropAreaView.frame)) / 2.0 + w;
    CGFloat bottom = CGRectGetHeight(self.frame) - CGRectGetMaxY(_cropAreaView.frame) + h;
    
    return UIEdgeInsetsMake(top, leftRight, bottom, leftRight);
}

- (CGPoint)calculateCenterContentOffsetWithContentInset:(UIEdgeInsets)contentInset {
    CGFloat w = MAX(0, (_scrollView.contentSize.width - CGRectGetWidth(_cropAreaView.frame)) / 2);
    CGFloat h = MAX(0, (_scrollView.contentSize.height - CGRectGetHeight(_cropAreaView.frame)) / 2);
    
    return CGPointMake(-contentInset.left + w, -contentInset.top + h);
}

#pragma mark Crop area available frame

- (CGRect)availableFrameToPlaceCropArea {
    return CGRectMake(0,
                      _topLayoutGuideLength,
                      CGRectGetWidth(self.frame),
                      CGRectGetHeight(self.frame) - _topLayoutGuideLength - CGRectGetHeight(_toolbar.frame));
}

#pragma mark UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView: (UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _imageView.center = CGPointMake(scrollView.contentSize.width / 2,
                                    scrollView.contentSize.height / 2);
    _scrollView.contentInset = [self calculateContentInset];
}

#pragma mark tap aspect ratio

- (void)tapAspectRatioOption:(id)sender {
    [_delegate imageCropViewDidTapAspectRatioChangeOption:self];
}

@end
