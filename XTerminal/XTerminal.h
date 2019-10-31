//
//  XTerminal.h
//  XTerminal
//
//  Created by Peter on 2019/10/31.
//Copyright © 2019 Peter. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface XTerminal : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end