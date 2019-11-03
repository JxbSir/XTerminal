//
//  NotificationController.h
//  XTerminal
//
//  Created by Peter on 2019/11/3.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationController : NSWindowController

@property (nonatomic, strong) IBOutlet NSTextField* label;

- (instancetype)initWithInfo:(NSString *)info;
@end

NS_ASSUME_NONNULL_END
