ImageCropViewController
=======================

Lightweight crop view controller.

```objective-c
ImageCropViewController *cropVC = [[ImageCropViewController alloc] initWithImage:image
                                                                     widthFactor:widthFactor
                                                                     heightFactor:heightFactor];
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
![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s2.png "screenshot")
