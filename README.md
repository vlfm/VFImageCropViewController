VFImageCropViewController
=======================

* Interactive resizable crop frame
* Fixed or not fixed aspect rario
* Standard aspect ratios: choose from the list

```objective-c
VFImageCropViewController *cropVC = [[VFImageCropViewController alloc]
                                      initWithImage:image aspectRatio:aspectRatio];
    
    cropVC.cropImageActionHandler = ^(VFImageCropViewController *sender, UIImage *image, CGRect rect) {
        myImageView.image = image;
        [myViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    cropVC.cancelActionHandler = ^(VFImageCropViewController *sender) {
        [myViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    UINavigationController *navigationVC = [VFImageCropConfiguration imageCropViewControllerModalConfiguration:cropVC];
```

Note ```VFImageCropConfiguration``` in the example above. ```VFImageCropViewController``` is not aware about its presentation context (whether it is presented with UINavigationController, etc). Presentation details must be configured explicitly by its client.

![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s1.png "screenshot")

![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s2.png "screenshot")

![Screenshot](https://raw.github.com/vlfm/ImageCropViewController/master/screenshots/s3.png "screenshot")
