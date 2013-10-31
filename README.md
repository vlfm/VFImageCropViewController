ImageCropViewController
=======================

Lightweight crop view controller.

```objective-c
ImageCropViewController *cropVC = [[ImageCropViewController alloc] initWithImage:image widthFactor:widthFactor heightFactor:heightFactor];
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
    
    [myViewController presentViewController:cropVC animated:YES completion:nil];
```

![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s1.png "screenshot")
![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s2.png "screenshot")
