#import <UIKit/UIKit.h>

@interface VFImageCropOverlayController : NSObject

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic) CGRect cropAreaRect;

@property (nonatomic) BOOL blurEnabled;

- (instancetype)initWithTargetView:(UIView *)targetView;

- (void)layout;

@end
