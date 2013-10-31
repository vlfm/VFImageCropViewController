#import "ImageCropViewController.h"
#import <QuartzCore/QuartzCore.h>

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
    
    {
        _toolbar = [UIToolbar new];
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"Move and scale";
        label.font = [UIFont boldSystemFontOfSize:20.0];
        [label sizeToFit];
        UIBarButtonItem *titleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
        
        _toolbar.items = @[
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           titleBarButtonItem,
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)]
                           
                           ];
        
        [self.view addSubview:_toolbar];
    }
    
    {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [_scrollView addSubview:_imageView];
        [self.view addSubview:_scrollView];
    }
    
    {
        CGFloat areaW = 0;
        CGFloat areaH = 0;
        
        if (_widthFactor >= _heightFactor) {
            areaW = self.view.frame.size.width - _cropFramePadding;
            areaH = (areaW / _widthFactor) * _heightFactor;
        } else {
            areaH = self.view.frame.size.height - kToolbarHeight - self.cropFramePadding;
            areaW = (areaH / _heightFactor) * _widthFactor;
        }
        
        _cropAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, areaW, areaH)];
        _cropAreaView.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height - kToolbarHeight) / 2.0);
        _cropAreaView.userInteractionEnabled = NO;
        
        _cropAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropAreaView.layer.borderWidth = 1;
        
        CGFloat leftRight = (self.view.frame.size.width - areaW) / 2.0;
        CGFloat topBottom = (self.view.frame.size.height - kToolbarHeight - areaH) / 2.0;
        _scrollView.contentInset = UIEdgeInsetsMake(topBottom, leftRight, topBottom, leftRight);
        
        [self.view addSubview:_cropAreaView];
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
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _scrollView.frame = CGRectMake(0,
                                   0,
                                   CGRectGetWidth(self.view.frame),
                                   CGRectGetHeight(self.view.frame) - kToolbarHeight);
    
    _toolbar.frame = CGRectMake(0,
                                CGRectGetHeight(self.view.frame) - kToolbarHeight,
                                CGRectGetWidth(self.view.frame),
                                kToolbarHeight);
}

- (CGRect)calculateCropRect {
    float zoomScale = 1.0 / [_scrollView zoomScale];
    
    CGRect cropRect;
    
    CGFloat dx = (CGRectGetWidth(_scrollView.frame) - CGRectGetWidth(_cropAreaView.frame)) / 2.0;
    CGFloat dy = (CGRectGetHeight(_scrollView.frame) - CGRectGetHeight(_cropAreaView.frame)) / 2.0;
    
	cropRect.origin.x = ([_scrollView contentOffset].x + dx) * zoomScale;
    cropRect.origin.y = ([_scrollView contentOffset].y + dy) * zoomScale;
    
    cropRect.size.width = CGRectGetWidth(_cropAreaView.frame) * zoomScale;
    cropRect.size.height = CGRectGetHeight(_cropAreaView.frame) * zoomScale;
    
    return cropRect;
}

#pragma mark - Actions

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

#pragma mark - Disable rotation

- (BOOL) shouldAutorotate {
    return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

#pragma mark - UIScrollViewDelegate

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