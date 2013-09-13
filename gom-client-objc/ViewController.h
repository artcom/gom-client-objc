//
//  ViewController.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GOMClient.h"

@interface ViewController : UIViewController <GOMClientDelegate>

@property (weak, nonatomic) IBOutlet UITextView *consoleView;

@end
