#import <UIKit/UIKit.h>

typedef void (^ vf_OnImageCropped) (UIImage *image, CGRect cropRect);
typedef void (^ vf_OnCancelled) ();

@interface VFImageCropViewController : UIViewController

@property (nonatomic) CGFloat cropFramePadding;

@property (nonatomic, copy) vf_OnImageCropped onImageCropped;
@property (nonatomic, copy) vf_OnCancelled onCancelled;

- (id)initWithImage:(UIImage *)image
        widthFactor:(NSInteger)widthFactor
       heightFactor:(NSInteger)heightFactor;

+ (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect;

@end