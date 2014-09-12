#import <UIKit/UIKit.h>

typedef void (^ vf_OnImageCropped) (UIImage *image, CGRect cropRect);
typedef void (^ vf_OnCancelled) ();

@class VFAspectRatio;

@interface VFImageCropViewController : UIViewController

@property (nonatomic) CGFloat cropFramePadding;

@property (nonatomic, copy) vf_OnImageCropped onImageCropped;
@property (nonatomic, copy) vf_OnCancelled onCancelled;

@property (nonatomic, copy) NSNumber *restoreStatusBarStyle;

@property (nonatomic) BOOL standardAspectRatiosAvailable;

- (instancetype)initWithImage:(UIImage *)image
                  widthFactor:(NSInteger)widthFactor
                 heightFactor:(NSInteger)heightFactor DEPRECATED_ATTRIBUTE ;

- (instancetype)initWithImage:(UIImage *)image aspectRatio:(VFAspectRatio *)aspectRatio;

+ (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect;

@end