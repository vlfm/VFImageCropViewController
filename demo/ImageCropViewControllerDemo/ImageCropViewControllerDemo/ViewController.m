#import "ViewController.h"
#import "ImageCropViewController.h"
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
    NSInteger widthFactor = CGRectGetWidth(imageView.frame);
    NSInteger heightFactor = CGRectGetHeight(imageView.frame);
    
    ImageCropViewController *cropVC = [[ImageCropViewController alloc] initWithImage:image widthFactor:widthFactor heightFactor:heightFactor];
    
    // set crop vc properties
    cropVC.cropFramePadding = 60;
    cropVC.toolBarTintColor = [UIColor whiteColor];
    
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
