#import "VFCropOverlayView.h"
#import "VFCropAreaView.h"

@implementation VFCropOverlayView {
    VFCropAreaView *_cropAreaView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.userInteractionEnabled = NO;
    
    _cropAreaView = [VFCropAreaView new];
    [self addSubview:_cropAreaView];
    
    return  self;
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

#pragma mark layout

- (void)layoutSubviews {
    [super layoutSubviews];
    _cropAreaView.frame = self.bounds;
}

# pragma mark private

- (CGRect)cropAreaRect {
    return self.frame;
}

@end