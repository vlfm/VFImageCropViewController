#import "ImageCropViewController.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat kToolbarHeight = 49;

@interface CropRectTransform : NSObject

+ (CGRect) transformRect: (CGRect)rect forImage: (UIImage *)image;

@end

@interface ImageCropViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIView *cropAreaView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSInteger widthFactor;
@property (nonatomic) NSInteger heightFactor;

- (CGRect) calculateCropRect;

@end

@implementation ImageCropViewController

+ (UIImage *) cropImage: (UIImage *)image withRect: (CGRect)cropRect
{
    CGRect cropRectTransformed = [CropRectTransform transformRect:cropRect forImage:image];
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRectTransformed);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
	CGImageRelease(imageRef);
	return cropped;
}

- (id) initWithImage: (UIImage *)image widthFactor: (NSInteger)widthFactor heightFactor: (NSInteger)heightFactor;
{
    self = [super init];
    self.image = image;
    self.widthFactor = widthFactor;
    self.heightFactor = heightFactor;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        UIToolbar *toolbar = [UIToolbar new];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        toolbar.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"Move and scale";
        label.font = [UIFont boldSystemFontOfSize:20.0];
        [label sizeToFit];
        UIBarButtonItem *titleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
        
        toolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         titleBarButtonItem,
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)],
                         nil];
        
        toolbar.frame = CGRectMake(0,
                                   self.view.frame.size.height - kToolbarHeight,
                                   self.view.frame.size.width,
                                   kToolbarHeight);
        [self.view addSubview:toolbar];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                  0,
                                                                                  self.view.frame.size.width,
                                                                                  self.view.frame.size.height - kToolbarHeight)];
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        [scrollView addSubview:imageView];
        [self.view addSubview:scrollView];
        
        self.scrollView = scrollView;
        self.imageView = imageView;
        
    }
    
    {
        CGFloat areaW = 0;
        CGFloat areaH = 0;
        
        if (self.widthFactor >= self.heightFactor) {
            areaW = self.view.frame.size.width;
            areaH = (areaW / self.widthFactor) * self.heightFactor;
        } else {
            areaH = self.view.frame.size.height - kToolbarHeight;
            areaW = (areaH / self.heightFactor) * self.widthFactor;
        }
        
        UIView *cropAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, areaW, areaH)];
        cropAreaView.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height - kToolbarHeight) / 2.0);
        cropAreaView.userInteractionEnabled = NO;
        
        cropAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        cropAreaView.layer.borderWidth = 1;
        
        CGFloat leftRight = (self.view.frame.size.width - areaW) / 2.0;
        CGFloat topBottom = (self.view.frame.size.height - kToolbarHeight - areaH) / 2.0;
        self.scrollView.contentInset = UIEdgeInsetsMake(topBottom, leftRight, topBottom, leftRight);
        
        [self.view addSubview:cropAreaView];
        self.cropAreaView = cropAreaView;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    float minimumZoomScale = self.scrollView.frame.size.width / self.imageView.frame.size.width;
    float maximumZoomScale = 2.0;
    
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.maximumZoomScale = maximumZoomScale;
    self.scrollView.minimumZoomScale = minimumZoomScale;
    self.scrollView.zoomScale = minimumZoomScale;
}

- (CGRect) calculateCropRect
{
    float zoomScale = 1.0 / [self.scrollView zoomScale];
    
    CGRect cropRect;
    
	cropRect.origin.x = [self.scrollView contentOffset].x * zoomScale;
    cropRect.origin.y = [self.scrollView contentOffset].y * zoomScale;
    
    cropRect.size.width = self.cropAreaView.frame.size.width * zoomScale;
    cropRect.size.height = self.cropAreaView.frame.size.height * zoomScale;
    
    return cropRect;
}

#pragma mark - Actions

- (void) cancel
{
    if (self.onCancelled) {self.onCancelled();}
}

- (void) done
{
    if (self.onImageCropped) {
        CGRect cropRect = [self calculateCropRect];
        UIImage *cropped = [ImageCropViewController cropImage:self.image withRect:cropRect];
        self.onImageCropped(cropped, cropRect);
    }
}

#pragma mark - Disable rotation

- (BOOL) shouldAutorotate
{
    return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView: (UIScrollView *)scrollView
{
	return self.imageView;
}

@end

@implementation CropRectTransform

+ (CGRect) transformRect: (CGRect)rect forImage: (UIImage *)image
{
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