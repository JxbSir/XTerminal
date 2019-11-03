//
//  NotificationController.m
//  XTerminal
//
//  Created by Peter on 2019/11/3.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "NotificationController.h"

@interface NotificationController ()
@property (nonatomic, copy) NSString* info;
@end

@implementation NotificationController

- (instancetype)initWithInfo:(NSString *)info
{
    self = [super initWithWindowNibName:@"NotificationController"];
    if (self) {
        self.info = info;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.label.stringValue = self.info;
    
}

@end
