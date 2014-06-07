VFImageCropViewController
=======================

Lightweight crop view controller.

```objective-c
VFImageCropViewController *cropVC = [[VFImageCropViewController alloc] initWithImage:image
                                                                       widthFactor:widthFactor
                                                                       heightFactor:heightFactor];
    // set crop vc properties
    cropVC.cropFramePadding = 60;
    
    cropVC.onCancelled = ^ {
        // ...
        [myViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    cropVC.onImageCropped = ^ (UIImage *image, CGRect rect) {
        // ...
        myImageView.image = image;
        [myViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:cropVC];
[myViewController presentViewController:navigationVC animated:YES completion:nil];
```

![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s.png "screenshot")