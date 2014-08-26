#import "VFImageCropView.h"
#import "VFAspectRatio.h"

@implementation VFImageCropView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIView *_cropAreaView;
    
    VFAspectRatio *_aspectRatio;
}

- (instancetype)initWithImage:(UIImage *)image
                  widthFactor:(NSInteger)widthFactor
                 heightFactor:(NSInteger)heightFactor {
    self = [super init];
    _image = image;
    _aspectRatio = [[VFAspectRatio alloc] initWithWidth:widthFactor height:heightFactor];
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
        _cropAreaView = [[UIView alloc] init];
        _cropAreaView.userInteractionEnabled = NO;
        
        _cropAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropAreaView.layer.borderWidth = 1;
        
        [self addSubview:_cropAreaView];
    }
    
    self.backgroundColor = [UIColor blackColor];
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    {
        _scrollView.frame = self.bounds;
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
    CGFloat areaW = 0;
    CGFloat areaH = 0;
    
    CGRect cropAvailableRect = [self availableFrameToPlaceCropArea];
    
    if (_aspectRatio.width >= _aspectRatio.height) {
        areaW = cropAvailableRect.size.width - _cropFramePadding;
        areaH = (areaW / _aspectRatio.width) * _aspectRatio.height;
    } else {
        areaH = cropAvailableRect.size.height - self.cropFramePadding;
        areaW = (areaH / _aspectRatio.height) * _aspectRatio.width;
    }
    
    _cropAreaView.frame = CGRectMake(0, 0, areaW, areaH);
    _cropAreaView.center = CGPointMake(CGRectGetMidX(cropAvailableRect), CGRectGetMidY(cropAvailableRect));
}

#pragma mark Crop area available frame

- (CGRect)availableFrameToPlaceCropArea {
    return CGRectMake(0,
                      _topLayoutGuideLength,
                      CGRectGetWidth(self.frame),
                      CGRectGetHeight(self.frame) - _topLayoutGuideLength);
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
