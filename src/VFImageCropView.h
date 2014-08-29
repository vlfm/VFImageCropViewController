#import <UIKit/UIKit.h>

@class VFAspectRatio;

@class VFImageCropView;
@protocol VFImageCropViewDelegate <NSObject>

- (void)imageCropViewDidTapAspectRatioChangeOption:(VFImageCropView *)imageCropView;

@end

@interface VFImageCropView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, weak, readonly) id<VFImageCropViewDelegate> delegate;
@property (nonatomic, readonly) CGRect cropRect;

@property (nonatomic) CGFloat cropFramePadding;
@property (nonatomic) CGFloat topLayoutGuideLength;

@property (nonatomic) VFAspectRatio *aspectRatio;

- (instancetype)initWithImage:(UIImage *)image delegate:(id<VFImageCropViewDelegate>)delegate;

- (void)loadView;

@end
