//
//  ViewController.m
//  HTN
//
//  Created by 3draw on 2017-09-16.
//  Copyright © 2017 3draw. All rights reserved.
//

#import "ViewController.h"
@import UIKit;



@interface ViewController ()
{
    NSArray *_pickerData;
}
@end



@implementation ViewController

int curr_row = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.Desired_Language.dataSource = self;
    self.Desired_Language.delegate = self;
    self.TextLabel1.text = @"";
    self.TextLabel2.text = @"";
    self.TextLabel3.text = @"";
    self.TextLabel1.hidden = true;
    self.TextLabel2.hidden = true;
    self.TextLabel3.hidden = true;
    
    self.PronunLabel1.text = @"";
    self.PronunLabel2.text = @"";
    self.PronunLabel3.text = @"";
    self.PronunLabel1.hidden = true;
    self.PronunLabel2.hidden = true;
    self.PronunLabel3.hidden = true;
    _pickerData = @[@"English", @"French", @"Italian", @"Swedish", @"Spanish", @"Estonian"];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    curr_row = row;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (IBAction)TakePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)SelectPhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.Screen.image = chosenImage;
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    NSString *base64 = [imageData base64Encoding];
    printf("______%s_______", base64);
    
    NSString *des_lan = @"en";
    
    if (curr_row == 1) {
        des_lan = @"fr";
    }
    else if (curr_row == 2) {
        des_lan = @"it";
    }
    else if (curr_row == 3) {
        des_lan = @"sv";
    }
    else if (curr_row == 4) {
        des_lan = @"es";
    }
    else if (curr_row == 5) {
        des_lan = @"et";
    }
    
    NSString *resultString = [NSString stringWithFormat:@"%@***%@", base64, des_lan];
    //NSString *resultString = base64;
    
    
    
    //NSURL* localUrl = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    
    //Function
    
    
    NSMutableURLRequest *req2 = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://165.227.46.196"]];
    [req2 setHTTPMethod:@"POST"];
    
    NSData *postData2 = [resultString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength2 = [NSString stringWithFormat:@"%lu",(unsigned long)[postData2 length]];
    
    [req2 addValue:postLength2 forHTTPHeaderField:@"Content-Length"];
    [req2 setHTTPBody:postData2];
    
    NSURLSession *session2 = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task2 = [session2 dataTaskWithRequest:req2
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                printf("WORKING");
                                                NSLog(@"%@", returnString);
                                                //printf("%s", response);
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self translateResults:returnString];
                                                });
                                            }];
    
    [task2 resume];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)translateResults:(NSString *) data {
    NSArray *array = [data componentsSeparatedByString:@"___"];
    
    NSLog(@"%@", array);
    
    int count = 0;
    
    self.TextLabel1.text = @"None";
    self.PronunLabel1.text = @"None";
    self.TextLabel2.text = @"None";
    self.PronunLabel2.text = @"None";
    self.TextLabel3.text = @"None";
    self.PronunLabel3.text = @"None";
    
    for (NSString *string in array)
    {
        NSLog(@"%@", string);
        NSString *label = @"None";
        NSString *pronun = @"None";
        NSString *new_string = [string stringByReplacingOccurrencesOfString:@"'" withString:@""];
        NSArray *innerArray = [new_string componentsSeparatedByString:@","];
        NSLog(@"%@", innerArray);
        
        if (count == 1) {
            if ([innerArray count] >= 2) {
                printf("Working");
                label = [innerArray objectAtIndex:0];
                pronun = [innerArray objectAtIndex:1];
            }
            self.TextLabel1.text = label;
            self.PronunLabel1.text = [pronun substringFromIndex:1];
        }
        
        if (count == 2) {
            if ([innerArray count] >= 2) {
                label = [innerArray objectAtIndex:0];
                pronun = [innerArray objectAtIndex:1];
            }
            self.TextLabel2.text = label;
            self.PronunLabel2.text = [pronun substringFromIndex:1];
        }
        
        if (count == 3) {
            if ([innerArray count] >= 2) {
                label = [innerArray objectAtIndex:0];
                pronun = [innerArray objectAtIndex:1];
            }
            self.TextLabel3.text = label;
            self.PronunLabel3.text = [pronun substringFromIndex:1];
        }
        
        count = count + 1;
    }
    
    self.TextLabel1.hidden = true;
    self.TextLabel2.hidden = true;
    self.TextLabel3.hidden = true;
    self.PronunLabel1.hidden = true;
    self.PronunLabel2.hidden = true;
    self.PronunLabel3.hidden = true;
    
    
    NSLog(@"%@", self.TextLabel1.text);
    NSLog(@"%@", self.PronunLabel1.text);
    
    if (![self.TextLabel1.text  isEqual: @"None"]) {
        self.TextLabel1.alpha = 0;
        self.TextLabel1.hidden = NO;
    }
    
    if (![self.TextLabel2.text  isEqual: @"None"]) {
        self.TextLabel2.alpha = 0;
        self.TextLabel2.hidden = NO;
    }
    
    if (![self.TextLabel3.text  isEqual: @"None"]) {
        self.TextLabel3.alpha = 0;
        self.TextLabel3.hidden = NO;
    }
    
    if ((![self.PronunLabel1.text  isEqual: self.TextLabel1.text]) && (![self.PronunLabel1.text  isEqual: @"None"])) {
        self.PronunLabel1.alpha = 0;
        self.PronunLabel1.hidden = NO;
    }
    
    if ((![self.PronunLabel2.text  isEqual: self.TextLabel2.text]) && (![self.PronunLabel2.text  isEqual: @"None"])) {
        self.PronunLabel2.alpha = 0;
        self.PronunLabel2.hidden = NO;
    }
    
    if ((![self.PronunLabel3.text  isEqual: self.TextLabel3.text]) && (![self.PronunLabel3.text  isEqual: @"None"])) {
        self.PronunLabel3.alpha = 0;
        self.PronunLabel3.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.TextLabel1.alpha = 1;
        self.TextLabel2.alpha = 1;
        self.TextLabel3.alpha = 1;
        self.PronunLabel1.alpha = 1;
        self.PronunLabel2.alpha = 1;
        self.PronunLabel3.alpha = 1;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
