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

#import <UIKit/UIKit.h>

@class VFAspectRatio;

@interface VFImageCropViewController : UIViewController

@property (nonatomic, copy) NSNumber *restoreStatusBarStyle;

@property (nonatomic) BOOL standardAspectRatiosAvailable;

- (instancetype)initWithImage:(UIImage *)image
                  widthFactor:(NSInteger)widthFactor
                 heightFactor:(NSInteger)heightFactor DEPRECATED_ATTRIBUTE ;

- (instancetype)initWithImage:(UIImage *)image aspectRatio:(VFAspectRatio *)aspectRatio;

+ (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect;

#pragma mark Action

- (void)cropImageAction;
- (void)cancelAction;

#pragma mark Action Callback

typedef void (^ vf_CropImageActionHandler) (VFImageCropViewController *sender, UIImage *image, CGRect cropRect);
typedef void (^ vf_CancelActionHandler) (VFImageCropViewController *sender);

@property (nonatomic, copy) vf_CropImageActionHandler cropImageActionHandler;
@property (nonatomic, copy) vf_CancelActionHandler cancelActionHandler;

@end