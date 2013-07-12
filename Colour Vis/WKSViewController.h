//
//  WKSViewController.h
//  Colour Vis
//
//  Created by Matt Patterson on 06/07/2013.
//  Copyright (c) 2013 Matt Patterson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@class WKSPieChart;

@interface WKSViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
}

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet WKSPieChart *thePie;
@property (strong, nonatomic) IBOutlet UIPopoverController *popover;

- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (void)scaleDownAndPosterize;

@end