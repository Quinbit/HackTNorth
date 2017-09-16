//
//  ViewController.h
//  HTN
//
//  Created by 3draw on 2017-09-16.
//  Copyright © 2017 3draw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *TextLabel1;
@property (weak, nonatomic) IBOutlet UILabel *TextLabel2;
@property (weak, nonatomic) IBOutlet UILabel *TextLabel3;
@property (weak, nonatomic) IBOutlet UILabel *PronunLabel1;
@property (weak, nonatomic) IBOutlet UILabel *PronunLabel2;
@property (weak, nonatomic) IBOutlet UILabel *PronunLabel3;
@property (strong, nonatomic) IBOutlet UIImageView *Screen;
- (IBAction)SelectPhoto:(UIButton *)sender;
- (IBAction)TakePhoto:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *Desired_Language;



@end
