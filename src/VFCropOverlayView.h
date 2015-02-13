#import <UIKit/UIKit.h>

@class VFAspectRatio;

@interface VFCropOverlayView : UIView

@property (nonatomic) VFAspectRatio *aspectRatio;
@property (nonatomic) UIEdgeInsets cropAreaMargins;

- (UIEdgeInsets)contentInsetsForImageScrollView:(UIScrollView *)scrollView;
- (CGPoint)centerContentOffsetForImageScrollView:(UIScrollView *)scrollView;
- (CGRect)cropRectWithImageScrollView:(UIScrollView *)scrollView;
- (CGFloat)minimumZoomScaleWithImage:(UIImage *)image;

@end