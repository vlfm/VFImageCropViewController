#import "ViewController.h"
#import "VFAspectRatio.h"
#import "VFImageCropViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (IBAction)photoAlbumButtonTap:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.navigationBar.clipsToBounds = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)cameraButtonTap:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) {
        return;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    [self presentViewController:cameraUI animated:YES completion:nil];
}

- (void)cropAndDisplayImage:(UIImage *)image picker:(UIImagePickerController *)picker {
    VFAspectRatio *aspectRatio = VFAspectRatioMake(CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
    VFImageCropViewController *cropVC = [[VFImageCropViewController alloc] initWithImage:image aspectRatio:aspectRatio];
    
    cropVC.cropFramePadding = 60;
    
    cropVC.onCancelled = ^ {
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    
    cropVC.onImageCropped = ^ (UIImage *image, CGRect rect) {
        imageView.image = image;
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:cropVC];
    [picker presentViewController:navigationVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) != kCFCompareEqualTo) {
        return;
    }
    
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    [self cropAndDisplayImage:image picker:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
