#import <UIKit/UIKit.h>

typedef void (^ OnImageCropped) (UIImage *image, CGRect cropRect);
typedef void (^ OnCancelled) ();

@interface ImageCropViewController : UIViewController

@property (nonatomic) CGFloat cropFramePadding;
@property (nonatomic) NSNumber *restoreStatusBarStyle;

@property (nonatomic, copy) OnImageCropped onImageCropped;
@property (nonatomic, copy) OnCancelled onCancelled;

- (id)initWithImage:(UIImage *)image
        widthFactor:(NSInteger)widthFactor
       heightFactor:(NSInteger)heightFactor;

+ (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect;

@end