#import "VFCropAreaView.h"

@implementation VFCropAreaView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.userInteractionEnabled = NO;
    
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
    
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

# pragma mark private

- (CGRect)cropAreaRect {
    return self.frame;
}

@end