//
//  ViewController.m
//  HTMCameraTranslator
//
//  Created by Quin Sykora on 9/16/17.
//  Copyright © 2017 Quin Sykora. All rights reserved.
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
    _pickerData = @[@"English", @"French", @"Korean", @"Russian", @"German", @"Japanese"];
    
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
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 1.0);
    NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSString *des_lan = @"en";
    
    if (curr_row == 2) {
        des_lan = @"fr";
    }
    else if (curr_row == 3) {
        des_lan = @"kr";
    }
    else if (curr_row == 4) {
        des_lan = @"ru";
    }
    else if (curr_row == 5) {
        des_lan = @"gr";
    }
    else if (curr_row == 6) {
        des_lan = @"jp";
    }
    
    NSString *resultString = [NSString stringWithFormat:@"%@/%@/%@", des_lan, @"_", base64];
    
    //NSURL* localUrl = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    
    //Function
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://10.20.235.7"]];
    [req setHTTPMethod:@"POST"];
    
    NSData *postData = [resultString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    [req addValue:postLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self translateResults:data];
                                                });
                                            }];
    
    [task resume];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
    
- (void)translateResults:(NSData *) data {
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *array = [newStr componentsSeparatedByString:@"___"];
    
    int count = 0;
    
    for (NSString *string in array)
    {
        NSString *label = @"None";
        NSString *pronun = @"None";
        NSArray *innerArray = [newStr componentsSeparatedByString:@","];
        if (count == 0) {
            if ([innerArray count] == 2) {
                label = [innerArray objectAtIndex:0];
                pronun = [innerArray objectAtIndex:1];
            }
            self.TextLabel1.text = label;
            self.PronunLabel1.text = pronun;
        }
        
        if (count == 1) {
            if ([innerArray count] == 2) {
                label = [innerArray objectAtIndex:0];
                pronun = [innerArray objectAtIndex:1];
            }
            self.TextLabel2.text = label;
            self.PronunLabel2.text = pronun;
        }
        
        if (count == 2) {
            if ([innerArray count] == 2) {
                label = [innerArray objectAtIndex:0];
                pronun = [innerArray objectAtIndex:1];
            }
            self.TextLabel3.text = label;
            self.PronunLabel3.text = pronun;
        }
        
    }
    
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
