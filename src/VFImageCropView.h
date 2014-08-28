#import <UIKit/UIKit.h>

@class VFAspectRatio;

@interface VFImageCropView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) CGRect cropRect;

@property (nonatomic) CGFloat cropFramePadding;
@property (nonatomic) CGFloat topLayoutGuideLength;

- (instancetype)initWithImage:(UIImage *)image aspectRatio:(VFAspectRatio *)aspectRatio;

- (void)loadView;

@end
