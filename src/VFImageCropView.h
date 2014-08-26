#import <UIKit/UIKit.h>

@interface VFImageCropView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) CGRect cropRect;

@property (nonatomic) CGFloat cropFramePadding;
@property (nonatomic) CGFloat topLayoutGuideLength;

- (instancetype)initWithImage:(UIImage *)image
                  widthFactor:(NSInteger)widthFactor
                 heightFactor:(NSInteger)heightFactor;

- (void)loadView;

@end
