#import <UIKit/UIKit.h>

@class VFAspectRatio;

@interface VFImageCropView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) CGRect cropRect;

@property (nonatomic) CGFloat cropFramePadding;
@property (nonatomic) CGFloat topLayoutGuideLength;

@property (nonatomic) VFAspectRatio *aspectRatio;

- (instancetype)initWithImage:(UIImage *)image;

- (void)loadView;

@end
