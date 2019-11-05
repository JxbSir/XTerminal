//
//  ProfileUtils.h
//  XTerminal
//
//  Created by Peter on 2019/11/5.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileUtils : NSObject

+ (instancetype)shared;
- (void)loadProfile:(void(^)(void))completion;

- (NSString *)getAliasByName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
