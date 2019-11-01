//
//  TerminalController.h
//  XTerminal
//
//  Created by Peter on 2019/10/31.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JBShellContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TerminalController : NSWindowController

@property (nonatomic, strong) IBOutlet JBShellContainerView* shellView;

- (instancetype)initWithProjectPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
