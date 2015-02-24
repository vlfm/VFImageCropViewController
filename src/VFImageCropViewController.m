/*
 
 Copyright 2014 Valery Fomenko
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "VFImageCropViewController.h"
#import "VFImageCropView.h"
#import "VFAspectRatio.h"

#define UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

@interface VFImageCropViewController () <UIActionSheetDelegate>
@end

@implementation VFImageCropViewController {
    NSArray *_aspectRatioList;
    VFImageCropView *_view;
    NSNumber *_savedStatusBarStyle;
}

#pragma mark Action

- (void)cropImageAction {
    if (self.cropImageActionHandler) {
        CGRect cropRect = _view.cropRect;
        UIImage *cropped = [VFImageCropViewController cropImage:_view.image withRect:cropRect];
        self.cropImageActionHandler(self, cropped, cropRect);
    }
}

- (void)cancelAction {
    if (self.cancelActionHandler) {
        self.cancelActionHandler(self);
    }
}

- (void)selectAspectRatioAction {
    UIActionSheet *actioSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (VFAspectRatio *aspectRatio in _aspectRatioList) {
        [actioSheet addButtonWithTitle:aspectRatio.description];
    }
    
    actioSheet.cancelButtonIndex = [actioSheet addButtonWithTitle:UIKitLocalizedString(@"Cancel")];
    
    [actioSheet showInView:_view];
}

+ (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect {
    CGRect cropRectTransformed = [self transformRect:cropRect forImage:image];
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRectTransformed);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
	CGImageRelease(imageRef);
	return cropped;
}

- (instancetype)initWithImage:(UIImage *)image {
    VFAspectRatio *aspectRatio = VFAspectRatioMake(image.size.width, image.size.height);
    return [self initWithImage:image aspectRatio:aspectRatio];
}

- (instancetype)initWithImage:(UIImage *)image aspectRatio:(VFAspectRatio *)aspectRatio {
    self = [super init];
    
    if (aspectRatio == nil) {
        aspectRatio = VFAspectRatioMake(image.size.width, image.size.height);
    }
    
    _aspectRatioList = [[self class] aspectRatioListWithImageSize:image.size firstApectRatio:aspectRatio];
    _view = [[VFImageCropView alloc] initWithImage:image];
    _view.aspectRatio = aspectRatio;
    return self;
}

- (VFAspectRatio *)aspectRatio {
    return _view.aspectRatio;
}

- (BOOL)aspectRatioFixed {
    return _view.aspectRatioFixed;
}

- (void)setAspectRatioFixed:(BOOL)aspectRatioFixed {
    _view.aspectRatioFixed = aspectRatioFixed;
}

- (id<VFEdgeInsetsGenerator>)cropAreaMargins {
    return _view.cropAreaMargins;
}

- (void)setCropAreaMargins:(id<VFEdgeInsetsGenerator>)cropAreaMargins {
    _view.cropAreaMargins = cropAreaMargins;
}

- (void)loadView {
    [_view loadView];
    self.view = _view;
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

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
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

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    VFAspectRatio *aspectRatio = _aspectRatioList[buttonIndex];
    _view.aspectRatio = aspectRatio;
    
    if (self.selectAspectRatioHandler) {
        self.selectAspectRatioHandler(self, aspectRatio);
    }
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

+ (NSArray *)aspectRatioListWithImageSize:(CGSize)imageSize firstApectRatio:(VFAspectRatio *)firstAspectRatio {
    if (imageSize.width >= imageSize.height) {
        
        return @[
                 firstAspectRatio,
                 VFAspectRatioMake(1, 1),
                 VFAspectRatioMake(3, 2),
                 VFAspectRatioMake(5, 3),
                 VFAspectRatioMake(4, 3),
                 VFAspectRatioMake(5, 4),
                 VFAspectRatioMake(7, 5),
                 VFAspectRatioMake(16, 9),
                 ];
        
    } else {
        
        return @[
                 firstAspectRatio,
                 VFAspectRatioMake(1, 1),
                 VFAspectRatioMake(2, 3),
                 VFAspectRatioMake(3, 5),
                 VFAspectRatioMake(3, 4),
                 VFAspectRatioMake(4, 5),
                 VFAspectRatioMake(5, 7),
                 VFAspectRatioMake(9, 16),
                 ];
        
    }
}

@end