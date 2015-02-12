#import <UIKit/UIKit.h>

@interface VFCropAreaView : UIView

- (UIEdgeInsets)contentInsetsForImageScrollView:(UIScrollView *)scrollView;
- (CGRect)cropRectWithImageScrollView:(UIScrollView *)scrollView;
- (CGFloat)minimumZoomScaleWithImage:(UIImage *)image;

@end