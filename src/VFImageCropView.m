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

#import "VFCropOverlayView.h"
#import "VFImageCropView.h"
#import "VFAspectRatio.h"

@implementation VFImageCropView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    VFCropOverlayView *_cropOverlayView;
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
    _cropOverlayView.cropFramePadding = cropFramePadding;
    [self setNeedsLayout];
}

- (void)setTopLayoutGuideLength:(CGFloat)topLayoutGuideLength {
    _topLayoutGuideLength = topLayoutGuideLength;
    _cropOverlayView.topLayoutGuideLength = topLayoutGuideLength;
}

- (CGRect)cropRect {
    return [_cropOverlayView cropRectWithImageScrollView:_scrollView];
}

- (void)setAspectRatio:(VFAspectRatio *)aspectRatio {
    _aspectRatio = aspectRatio;
    _cropOverlayView.aspectRatio = aspectRatio;
    
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
        _cropOverlayView = [VFCropOverlayView new];
        _cropOverlayView.aspectRatio = _aspectRatio;
        _cropOverlayView.cropFramePadding = _cropFramePadding;
        _cropOverlayView.topLayoutGuideLength = _topLayoutGuideLength;
        [self addSubview:_cropOverlayView];
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
        _cropOverlayView.frame = [self cropOverlayAvailableRect];
        
        CGFloat minimumZoomScale = [_cropOverlayView minimumZoomScaleWithImage:_image];
        
        _scrollView.contentSize = _imageView.frame.size;
        _scrollView.minimumZoomScale = minimumZoomScale;
        _scrollView.contentInset = [_cropOverlayView contentInsetsForImageScrollView:_scrollView];
        
        if (_needsUpdateZoomScaleNextLayout) {
            _scrollView.zoomScale = minimumZoomScale;
            _needsUpdateZoomScaleNextLayout = NO;
        }
        
        if (_scrollView.zoomScale < minimumZoomScale) {
            _scrollView.zoomScale = minimumZoomScale;
        }
        
        _scrollView.contentOffset = [_cropOverlayView centerContentOffsetForImageScrollView:_scrollView];
    }
}

#pragma mark Crop area available frame

- (CGRect)cropOverlayAvailableRect {
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
    _scrollView.contentInset = [_cropOverlayView contentInsetsForImageScrollView:scrollView];
}

#pragma mark tap aspect ratio

- (void)tapAspectRatioOption:(id)sender {
    [_delegate imageCropViewDidTapAspectRatioChangeOption:self];
}

@end
