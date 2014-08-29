#import "VFImageCropViewController.h"
#import "VFImageCropView.h"
#import <QuartzCore/QuartzCore.h>
#import "VFAspectRatio.h"

@interface VFImageCropViewController () <VFImageCropViewDelegate>
@end

@implementation VFImageCropViewController {
    VFImageCropView *_view;
    NSNumber *_savedStatusBarStyle;
}

+ (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect {
    CGRect cropRectTransformed = [self transformRect:cropRect forImage:image];
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRectTransformed);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
	CGImageRelease(imageRef);
	return cropped;
}

- (instancetype)initWithImage:(UIImage *)image
                  widthFactor:(NSInteger)widthFactor
                 heightFactor:(NSInteger)heightFactor {
    
    return [self initWithImage:image aspectRatio:[[VFAspectRatio alloc] initWithWidth:widthFactor
                                                                               height:heightFactor]];
}

- (instancetype)initWithImage:(UIImage *)image aspectRatio:(VFAspectRatio *)aspectRatio {
    self = [super init];
    _view = [[VFImageCropView alloc] initWithImage:image delegate:self];
    _view.aspectRatio = aspectRatio;
    return self;
}

- (void)loadView {
    [_view loadView];
    self.view = _view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel)];
        
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self action:@selector(done)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self applyNewStatusBarStyle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self restorePreviousStatusBarStyle];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _view.topLayoutGuideLength = self.topLayoutGuide.length;
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

#pragma mark Property

- (CGFloat)cropFramePadding {
    return _view.cropFramePadding;
}

- (void)setCropFramePadding:(CGFloat)cropFramePadding {
    _view.cropFramePadding = cropFramePadding;
}

#pragma mark Actions

- (void)cancel {
    if (self.onCancelled) {self.onCancelled();}
}

- (void)done {
    if (self.onImageCropped) {
        CGRect cropRect = _view.cropRect;
        UIImage *cropped = [VFImageCropViewController cropImage:_view.image withRect:cropRect];
        self.onImageCropped(cropped, cropRect);
    }
}

#pragma mark Status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)applyNewStatusBarStyle {
    _savedStatusBarStyle = _restoreStatusBarStyle;
    
    if (_savedStatusBarStyle == nil) {
        _savedStatusBarStyle = @([UIApplication sharedApplication].statusBarStyle);
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)restorePreviousStatusBarStyle {
    [UIApplication sharedApplication].statusBarStyle = [_savedStatusBarStyle integerValue];
}

#pragma mark VFImageCropViewDelegate

- (void)imageCropViewDidTapAspectRatioChangeOption:(VFImageCropView *)imageCropView {
    NSLog(@"aspect ratio tap");
}

#pragma mark Crop Rect Transform

+ (CGRect)transformRect:(CGRect)rect forImage:(UIImage *)image {
    CGRect new = rect;
    UIImageOrientation imageOrientation = image.imageOrientation;
    CGSize imageSize = image.size;
    
    if (imageOrientation == UIImageOrientationLeft) {
        
        new.size.width  = rect.size.height;
        new.size.height = rect.size.width;
        new.origin.y = rect.origin.x;
        new.origin.x = imageSize.height - rect.size.height - rect.origin.y;
        
    } else if (imageOrientation == UIImageOrientationRight) {
        
        new.size.width  = rect.size.height;
        new.size.height = rect.size.width;
        new.origin.x = rect.origin.y;
        new.origin.y = imageSize.width - rect.size.width - rect.origin.x;
        
    } else if (imageOrientation == UIImageOrientationDown) {
        
        new.origin.x = imageSize.width - rect.size.width - rect.origin.x;
        new.origin.y = imageSize.height - rect.size.height - rect.origin.y;
    }
    
    return new;
}

@end