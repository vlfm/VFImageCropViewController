#import "ImageCropViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static CGFloat kStatusBarHeight = 20;
static CGFloat kToolbarHeight = 49;

@interface CropRectTransform : NSObject
+ (CGRect)transformRect:(CGRect)rect forImage:(UIImage *)image;
@end

@interface ImageCropViewController () <UIScrollViewDelegate>
@end

@implementation ImageCropViewController {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIView *_cropAreaView;
    UIToolbar *_toolbar;
    
    UIImage *_image;
    NSInteger _widthFactor;
    NSInteger _heightFactor;
}

+ (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect {
    CGRect cropRectTransformed = [CropRectTransform transformRect:cropRect forImage:image];
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRectTransformed);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
	CGImageRelease(imageRef);
	return cropped;
}

- (id)initWithImage:(UIImage *)image widthFactor:(NSInteger)widthFactor heightFactor:(NSInteger)heightFactor {
    self = [super init];
    _image = image;
    _widthFactor = widthFactor;
    _heightFactor = heightFactor;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wantsFullScreenLayout = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_scrollView addSubview:_imageView];
        [self.view addSubview:_scrollView];
    }
    
    {
        CGFloat areaW = 0;
        CGFloat areaH = 0;
        
        CGSize cropAvailableSize = [self availableFrameToPlaceCropArea].size;
        
        if (_widthFactor >= _heightFactor) {
            areaW = cropAvailableSize.width - _cropFramePadding;
            areaH = (areaW / _widthFactor) * _heightFactor;
        } else {
            areaH = cropAvailableSize.height - self.cropFramePadding;
            areaW = (areaH / _heightFactor) * _widthFactor;
        }
        
        _cropAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, areaW, areaH)];
        _cropAreaView.userInteractionEnabled = NO;
        
        _cropAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropAreaView.layer.borderWidth = 1;
        
        [self.view addSubview:_cropAreaView];
    }
    
    {
        _toolbar = [UIToolbar new];
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.backgroundColor = [UIColor clearColor];
        
        _toolbar.items = @[
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)]
                           
                           ];
        
        [self.view addSubview:_toolbar];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    float minimumZoomScale = CGRectGetWidth(_cropAreaView.frame) / CGRectGetWidth(_imageView.frame);
    float maximumZoomScale = 2.0;
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.maximumZoomScale = maximumZoomScale;
    _scrollView.minimumZoomScale = minimumZoomScale;
    _scrollView.zoomScale = minimumZoomScale;
    
    [self applyNewStatusBarStyle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self restorePreviousStatusBarStyle];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect cropAvailableRect = [self availableFrameToPlaceCropArea];
    _cropAreaView.center = CGPointMake(CGRectGetMidX(cropAvailableRect), CGRectGetMidY(cropAvailableRect));
    
    _toolbar.frame = CGRectMake(0,
                                CGRectGetHeight(self.view.frame) - kToolbarHeight,
                                CGRectGetWidth(self.view.frame),
                                kToolbarHeight);
    
    CGFloat top = CGRectGetMinY(_cropAreaView.frame);
    CGFloat leftRight = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(_cropAreaView.frame)) / 2.0;
    CGFloat bottom = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(_cropAreaView.frame);
    _scrollView.contentInset = UIEdgeInsetsMake(top, leftRight, bottom, leftRight);
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (CGRect)calculateCropRect {
    float zoomScale = 1.0 / [_scrollView zoomScale];
    
    CGRect cropRect;
    
    CGFloat dx = CGRectGetMinX(_cropAreaView.frame);
    CGFloat dy = CGRectGetMinY(_cropAreaView.frame);
    
	cropRect.origin.x = ([_scrollView contentOffset].x + dx) * zoomScale;
    cropRect.origin.y = ([_scrollView contentOffset].y + dy) * zoomScale;
    
    cropRect.size.width = CGRectGetWidth(_cropAreaView.frame) * zoomScale;
    cropRect.size.height = CGRectGetHeight(_cropAreaView.frame) * zoomScale;
    
    return cropRect;
}

#pragma mark Actions

- (void) cancel {
    if (self.onCancelled) {self.onCancelled();}
}

- (void) done {
    if (self.onImageCropped) {
        CGRect cropRect = [self calculateCropRect];
        UIImage *cropped = [ImageCropViewController cropImage:_image withRect:cropRect];
        self.onImageCropped(cropped, cropRect);
    }
}

#pragma mark Crop area available frame

- (CGRect)availableFrameToPlaceCropArea {
    return CGRectMake(0,
                      kStatusBarHeight,
                      CGRectGetWidth(self.view.frame),
                      CGRectGetHeight(self.view.frame) - kToolbarHeight - kStatusBarHeight);
}

#pragma mark Disable rotation

- (BOOL) shouldAutorotate {
    return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

#pragma mark UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView: (UIScrollView *)scrollView {
	return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (_cropAreaView.bounds.size.width > scrollView.contentSize.width)?
    (_cropAreaView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (_cropAreaView.bounds.size.height > scrollView.contentSize.height)?
    (_cropAreaView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark Status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)applyNewStatusBarStyle {
    if (_restoreStatusBarStyle == nil) {
        _restoreStatusBarStyle = @([UIApplication sharedApplication].statusBarStyle);
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    }
}

- (void)restorePreviousStatusBarStyle {
    [UIApplication sharedApplication].statusBarStyle = [_restoreStatusBarStyle integerValue];
}

@end

@implementation CropRectTransform

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