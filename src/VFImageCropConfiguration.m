#import "VFImageCropConfiguration.h"

#import "VFImageCropViewController.h"

@implementation VFImageCropConfiguration

+ (UINavigationController *)imageCropViewControllerModalConfiguration:(VFImageCropViewController *)vc {
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                           target:vc action:@selector(cancelAction)];
    
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                            target:vc action:@selector(cropImageAction)];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    return nc;
}

@end
