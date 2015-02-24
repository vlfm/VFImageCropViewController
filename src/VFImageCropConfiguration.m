/*
 
 Copyright 2015 Valery Fomenko
 
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

#import "VFImageCropConfiguration.h"

#import "VFAspectRatio.h"
#import "VFEdgeInsetsGenerator.h"
#import "VFImageCropViewController.h"

@interface VFLayoutGuideEdgeInsetsGenerator : NSObject <VFEdgeInsetsGenerator>

- (instancetype)initWithViewController:(UIViewController *)vc margin:(CGFloat)margin;

@end

@implementation VFLayoutGuideEdgeInsetsGenerator {
    __weak UIViewController *_vc;
    CGFloat _margin;
}

- (instancetype)initWithViewController:(UIViewController *)vc margin:(CGFloat)margin {
    self = [super init];
    _vc = vc;
    _margin = margin;
    return self;
}

- (UIEdgeInsets)edgeInsetsWithBounds:(CGSize)bounds {
    CGFloat top = _vc.topLayoutGuide.length + _margin;
    CGFloat bottom = _vc.bottomLayoutGuide.length + _margin;
    return UIEdgeInsetsMake(top, _margin, bottom, _margin);
}

@end



@implementation VFImageCropConfiguration

- (instancetype)init {
    self = [super init];
    self.selectAspectRatioActionAvailable = YES;
    return self;
}

- (UINavigationController *)imageCropViewControllerModalConfiguration:(VFImageCropViewController *)vc {
    vc.toolbarItems = [self toolbarApectRatioItemsWithImageCropViewController:vc];
    vc.selectAspectRatioHandler = ^(VFImageCropViewController *sender, VFAspectRatio *aspectRatio) {
        sender.toolbarItems = [self toolbarApectRatioItemsWithImageCropViewController:sender];
    };
    
    vc.cropAreaMargins = [[VFLayoutGuideEdgeInsetsGenerator alloc] initWithViewController:vc margin:10];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.navigationBarHidden = YES;
    nc.toolbarHidden = NO;
    nc.toolbar.barStyle = UIBarStyleBlack;
    
    return nc;
}

- (NSArray *)toolbarApectRatioItemsWithImageCropViewController:(VFImageCropViewController *)vc {
    UIBarButtonItem *cancelItem = [self cancelActionBarButtonItemWithImageCropViewController:vc];
    UIBarButtonItem *cropImageItem = [self cropImageActionBarButtonItemWithImageCropViewController:vc];
    UIBarButtonItem *selectAspectRatioItem = [self selectAspectRatioActionBarButtonItemWithImageCropViewController:vc];
    
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:cancelItem];
    [items addObject:[self flexibleSpaceBarButtonItem]];
    
    if (self.selectAspectRatioActionAvailable) {
        [items addObject:selectAspectRatioItem];
        [items addObject:[self flexibleSpaceBarButtonItem]];
    }
    
    [items addObject:cropImageItem];
    
    return items;
}

#pragma mark bar button items

- (UIBarButtonItem *)cancelActionBarButtonItemWithImageCropViewController:(VFImageCropViewController *)vc {
    return [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                        target:vc action:@selector(cancelAction)];
}

- (UIBarButtonItem *)cropImageActionBarButtonItemWithImageCropViewController:(VFImageCropViewController *)vc {
    return [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                        target:vc action:@selector(cropImageAction)];
}

- (UIBarButtonItem *)selectAspectRatioActionBarButtonItemWithImageCropViewController:(VFImageCropViewController *)vc {
    return [[UIBarButtonItem alloc] initWithTitle:vc.aspectRatio.description
                                            style:UIBarButtonItemStylePlain
                                           target:vc action:@selector(selectAspectRatioAction)];
}

- (UIBarButtonItem *)flexibleSpaceBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

@end
