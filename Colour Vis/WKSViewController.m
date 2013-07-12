//
//  WKSViewController.m
//  Colour Vis
//
//  Created by Matt Patterson on 06/07/2013.
//  Copyright (c) 2013 Matt Patterson. All rights reserved.
//

#import "WKSViewController.h"
#import "WKSPieChart.h"

@interface WKSViewController ()

@end

@implementation WKSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(id)sender {
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO))
        return;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];

}

- (IBAction)selectPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Set the sender to a UIButton.
        UIButton *tappedButton = (UIButton *)sender;
        self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];

    self.photoImageView.image = photo;
    [self scaleDownAndPosterize];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



- (void)scaleDownAndPosterize
{
    UIImage *original = self.photoImageView.image;
    CGFloat width = original.size.width;
    CGFloat height = original.size.height;
    
    CGFloat scale = width > height ? 100.0 / width : 100.0 / height;
    
    CIImage *outputImage;
    CIFilter *resize_filter = [CIFilter filterWithName:@"CILanczosScaleTransform" keysAndValues: @"inputScale", @(scale), @"inputAspectRatio", @1.0, @"inputImage", [[CIImage alloc] initWithImage:original], nil];
    
    outputImage = [resize_filter outputImage];
    CIFilter *posterize_filter = [CIFilter filterWithName:@"CIColorPosterize" keysAndValues: @"inputImage",
                                  outputImage, @"inputLevels", @10, nil];
    outputImage = [posterize_filter outputImage];

    
    // make CIContext
    CIContext *ci_context = [CIContext contextWithOptions:nil];

    CGImageRef histogramCG = [ci_context createCGImage:outputImage fromRect:[outputImage extent]];
    
//    NSLog(@"size: %zd x %zd", CGImageGetWidth (histogramCG), CGImageGetHeight(histogramCG));

    UIImage *newImage = [UIImage imageWithCIImage:outputImage];

    self.photoImageView.image = newImage;


    // bit depth
    size_t bit_depth = CGImageGetBitsPerComponent (histogramCG);
    // does it have alpha?
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo (histogramCG);
    // bpp?
    size_t bpp = CGImageGetBitsPerPixel (histogramCG);
    
//    NSLog(@"%zd --- %zd --- %d", bpp, bit_depth, alpha);
    // iterate over the pixels
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(histogramCG));
    UInt8 pixelDataBuffer[4];
    
    int pixelDataLength = CFDataGetLength (pixelData);
    int pixelByteSize = bpp / 8;
    
//    NSLog(@"%d", pixelByteSize);
    
    NSMutableDictionary *histogram = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < pixelDataLength; i += 4) {
        CFDataGetBytes(pixelData, CFRangeMake(i, 4), pixelDataBuffer);
        NSString *pixelAsHex = [NSString stringWithFormat:@"%02x.%02x.%02x", pixelDataBuffer[0], pixelDataBuffer[1], pixelDataBuffer[2]];
        if ([histogram objectForKey:pixelAsHex] != nil) {
            NSNumber *count = [histogram objectForKey:pixelAsHex];
            count = @([count integerValue] + 1);
            [histogram setObject:count forKey:pixelAsHex];
        }
        else {
            [histogram setObject:@(1) forKey:pixelAsHex];
        }
    }
//    NSLog(@"%@", histogram);
//    NSLog(@"%d", [[histogram allKeys] count]);
    
    [self.thePie setColourFreqDict:histogram];
    [self.thePie setNeedsDisplay];
}
@end
