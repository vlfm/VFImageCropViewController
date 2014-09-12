VFImageCropViewController
=======================

Lightweight crop view controller.

```objective-c
VFImageCropViewController *cropVC = [[VFImageCropViewController alloc]
                                      initWithImage:image aspectRatio:VFAspectRatioMake(w, h)];
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

![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s1.png "screenshot")

Aspects (new in 2.1.0)
==
Choose crop aspect ratio from list with standars values. Initial (user provided) aspect ratio is on top.
Available by default, can be disabled:
```objective-c
cropVC.standardAspectRatiosAvailable = NO;
```

![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s2.png "screenshot")
