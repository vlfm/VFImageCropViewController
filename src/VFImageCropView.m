#import "VFImageCropView.h"
#import "VFAspectRatio.h"

@implementation VFImageCropView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIView *_cropAreaView;
    UIToolbar *_toolbar;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    _image = image;
    return self;
}

- (void)setCropFramePadding:(CGFloat)cropFramePadding {
    _cropFramePadding = cropFramePadding;
    [self layoutCropAreaView];
}

- (CGRect)cropRect {
    float zoomScale = 1.0 / [_scrollView zoomScale];
    
    CGRect cropRect;
    
    CGFloat dx = CGRectGetMinX(_cropAreaView.frame);
    CGFloat dy = CGRectGetMinY(_cropAreaView.frame);
    
    cropRect.origin.x = ([_scrollView contentOffset].x + dx) * zoomScale;
    cropRect.origin.y = ([_scrollView contentOffset].y + dy) * zoomScale;
    
    cropRect.size.width = CGRectGetWidth(_cropAreaView.frame) * zoomScale;
    cropRect.size.height = CGRectGetHeight(_cropAreaView.frame) * zoomScale;
    
    return cropRect;
}

- (void)setAspectRatio:(VFAspectRatio *)aspectRatio {
    _aspectRatio = aspectRatio;
    
    BOOL isLoaded = (_toolbar != nil);
    
    if (isLoaded) {
        
        _toolbar.items = @[
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:_aspectRatio.description
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
                           ];
        
        [self setNeedsLayout];
        
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
        
        [_scrollView addSubview:_imageView];
        [self addSubview:_scrollView];
    }
    
    {
        _cropAreaView = [UIView new];
        _cropAreaView.userInteractionEnabled = NO;
        
        _cropAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropAreaView.layer.borderWidth = 1;
        
        [self addSubview:_cropAreaView];
    }
    
    {
        _toolbar = [UIToolbar new];
        _toolbar.barStyle = UIBarStyleBlack;
        
        _toolbar.items = @[
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:_aspectRatio.description
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
                           ];
        
        [self addSubview:_toolbar];
    }
    
    self.backgroundColor = [UIColor blackColor];
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
    
    [self layoutCropAreaView];
    
    {
        float minimumZoomScale = CGRectGetWidth(_cropAreaView.frame) / _image.size.width;
        float maximumZoomScale = 2.0;
        
        _scrollView.contentSize = _imageView.frame.size;
        _scrollView.maximumZoomScale = maximumZoomScale;
        _scrollView.minimumZoomScale = minimumZoomScale;
        _scrollView.zoomScale = minimumZoomScale;
    }
    
    {
        CGFloat top = CGRectGetMinY(_cropAreaView.frame);
        CGFloat leftRight = (CGRectGetWidth(self.frame) - CGRectGetWidth(_cropAreaView.frame)) / 2.0;
        CGFloat bottom = CGRectGetHeight(self.frame) - CGRectGetMaxY(_cropAreaView.frame);
        _scrollView.contentInset = UIEdgeInsetsMake(top, leftRight, bottom, leftRight);
    }
}

- (void)layoutCropAreaView {
    CGRect cropAvailableRect = [self availableFrameToPlaceCropArea];
    
    CGSize areaSize = [_aspectRatio aspectSizeThatFits:cropAvailableRect.size
                                               padding:_cropFramePadding];
    
    _cropAreaView.frame = CGRectMake(0, 0, areaSize.width, areaSize.height);
    _cropAreaView.center = CGPointMake(CGRectGetMidX(cropAvailableRect), CGRectGetMidY(cropAvailableRect));
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
    CGFloat offsetX = (_cropAreaView.bounds.size.width > scrollView.contentSize.width)?
    (_cropAreaView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (_cropAreaView.bounds.size.height > scrollView.contentSize.height)?
    (_cropAreaView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

@end
