#import <UIKit/UIKit.h>

@interface VFImageCropOverlayController : NSObject

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic) CGRect cropAreaRect;

- (instancetype)initWithTargetView:(UIView *)targetView;

- (void)layout;

@end
