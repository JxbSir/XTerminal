//
//  XUtils.h
//  XTerminal
//
//  Created by Peter on 2019/10/31.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XUtils : NSObject

+ (id)execute:(NSString *)cmd;

+ (BOOL)runProcessAsAdministrator:(NSString *)scriptPath arguments:(NSArray *)arguments isAdmin:(BOOL)isAdmin output:(NSString **)output errorDescription:(NSString **)errorDescription;
@end

NS_ASSUME_NONNULL_END
