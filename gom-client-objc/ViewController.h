//
//  ViewController.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GOMClient.h"
#import "ObserverViewController.h"

@interface ViewController : UIViewController <GOMClientDelegate, ObserverViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *consoleView;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;
@property (weak, nonatomic) IBOutlet UITextField *attributeField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *observerButton;

- (IBAction)sendToGOM:(id)sender;
- (IBAction)manageObservers:(id)sender;
@end
