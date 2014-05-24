#import "ImageCropViewController.h"
#import <QuartzCore/QuartzCore.h>

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

@interface ImageCropViewController () <UIScrollViewDelegate>
@end

@implementation ImageCropViewController {
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

- (id)initWithImage:(UIImage *)image widthFactor:(NSInteger)widthFactor heightFactor:(NSInteger)heightFactor {
    self = [super init];
    _view = [[VFImageCropView alloc] initWithImage:image
                                       widthFactor:widthFactor
                                      heightFactor:heightFactor];
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
        UIImage *cropped = [ImageCropViewController cropImage:_view.image withRect:cropRect];
        self.onImageCropped(cropped, cropRect);
    }
}

#pragma mark Status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)applyNewStatusBarStyle {
    if (_savedStatusBarStyle == nil) {
        _savedStatusBarStyle = @([UIApplication sharedApplication].statusBarStyle);
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)restorePreviousStatusBarStyle {
    [UIApplication sharedApplication].statusBarStyle = [_savedStatusBarStyle integerValue];
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

@implementation VFImageCropView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIView *_cropAreaView;
    UIToolbar *_toolbar;
    
    NSInteger _widthFactor;
    NSInteger _heightFactor;
}

- (instancetype)initWithImage:(UIImage *)image
                  widthFactor:(NSInteger)widthFactor
                 heightFactor:(NSInteger)heightFactor {
    self = [super init];
    _image = image;
    _widthFactor = widthFactor;
    _heightFactor = heightFactor;
    return self;
}

- (void)setCropFramePadding:(CGFloat)cropFramePadding {
    _cropFramePadding = cropFramePadding;
    [self layoutCropAreaView];
}

- (CGRect)cropRect {
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

- (void)loadView {
    
    {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_scrollView addSubview:_imageView];
        [self addSubview:_scrollView];
    }
    
    {
        _cropAreaView = [[UIView alloc] init];
        _cropAreaView.userInteractionEnabled = NO;
        
        _cropAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropAreaView.layer.borderWidth = 1;
        
        [self addSubview:_cropAreaView];
    }
    
    {
        _toolbar = [UIToolbar new];
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_toolbar];
        
        self.backgroundColor = [UIColor blackColor];
    }
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    {
        _scrollView.frame = self.bounds;
    }
    
    {
        [_toolbar sizeToFit];
        _toolbar.frame = CGRectMake(CGRectGetMinX(_toolbar.frame),
                                    self.bounds.size.height - CGRectGetHeight(_toolbar.frame),
                                    CGRectGetWidth(_toolbar.frame),
                                    CGRectGetHeight(_toolbar.frame));
    }
    
    [self layoutCropAreaView];
    
    {
        float minimumZoomScale = CGRectGetWidth(_cropAreaView.frame) / _image.size.width;
        float maximumZoomScale = 2.0;
        
        _scrollView.contentSize = _imageView.frame.size;
        _scrollView.maximumZoomScale = maximumZoomScale;
        _scrollView.minimumZoomScale = minimumZoomScale;
        _scrollView.zoomScale = minimumZoomScale;
    }
    
    {
        CGFloat top = CGRectGetMinY(_cropAreaView.frame);
        CGFloat leftRight = (CGRectGetWidth(self.frame) - CGRectGetWidth(_cropAreaView.frame)) / 2.0;
        CGFloat bottom = CGRectGetHeight(self.frame) - CGRectGetMaxY(_cropAreaView.frame);
        _scrollView.contentInset = UIEdgeInsetsMake(top, leftRight, bottom, leftRight);
    }
}

- (void)layoutCropAreaView {
    CGFloat areaW = 0;
    CGFloat areaH = 0;
    
    CGRect cropAvailableRect = [self availableFrameToPlaceCropArea];
    
    if (_widthFactor >= _heightFactor) {
        areaW = cropAvailableRect.size.width - _cropFramePadding;
        areaH = (areaW / _widthFactor) * _heightFactor;
    } else {
        areaH = cropAvailableRect.size.height - self.cropFramePadding;
        areaW = (areaH / _heightFactor) * _widthFactor;
    }
        
    _cropAreaView.frame = CGRectMake(0, 0, areaW, areaH);
    _cropAreaView.center = CGPointMake(CGRectGetMidX(cropAvailableRect), CGRectGetMidY(cropAvailableRect));
}

#pragma mark Crop area available frame

- (CGRect)availableFrameToPlaceCropArea {
    return CGRectMake(0,
                      _topLayoutGuideLength,
                      CGRectGetWidth(self.frame),
                      CGRectGetHeight(self.frame) - _topLayoutGuideLength - _toolbar.frame.size.height);
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

@end