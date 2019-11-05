//
//  ProfileUtils.m
//  XTerminal
//
//  Created by Peter on 2019/11/5.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "ProfileUtils.h"
#import "PipeTask.h"

@interface ProfileUtils ()
@property (nonatomic, strong) PipeTask* task;

@property (nonatomic, strong) NSDictionary* aliasDict;
@end

@implementation ProfileUtils

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static ProfileUtils *util;
    dispatch_once(&onceToken, ^{
        util = [ProfileUtils new];
    });
    
    return util;
}


- (void)loadProfile:(void(^)(void))completion {
    NSString* profileCmd = @"cat ~/.bash_profile";
    
    __weak typeof(self) wself = self;
    
    _task = [[PipeTask alloc] initWithRootPath:@"~/"];
    [_task execute:profileCmd completion:^(NSString * _Nonnull text) {
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        
        NSArray* list = [text componentsSeparatedByString:@"\n"];
        [list enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj && obj.length > 0) {
                NSString* value = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (![value hasPrefix:@"#"] && [obj hasPrefix:@"alias"]) {
                    NSString* namePattern = @"(?<=alias ).*?(?==)";
                    NSRegularExpression* nameRegular = [[NSRegularExpression alloc] initWithPattern:namePattern options:NSRegularExpressionCaseInsensitive error:nil];
                    NSTextCheckingResult* nameResult = [nameRegular firstMatchInString:value options:NSMatchingReportCompletion range:NSMakeRange(0, value.length)];
                    NSString* aliasName = [value substringWithRange:nameResult.range];
                    
                    NSString* valuePattern = @"(?<=').*?(?=')";
                    NSRegularExpression* valueRegular = [[NSRegularExpression alloc] initWithPattern:valuePattern options:NSRegularExpressionCaseInsensitive error:nil];
                    NSTextCheckingResult* valueResult = [valueRegular firstMatchInString:value options:NSMatchingReportCompletion range:NSMakeRange(0, value.length)];
                    NSString* aliasValue = [value substringWithRange:valueResult.range];
             
                    [dict setObject:aliasValue forKey:aliasName];
                }
                
            }
        }];
        
        wself.aliasDict = dict;
        
    } finish:^{
        wself.task = nil;
        completion();
    }];
}

- (NSString *)getAliasByName:(NSString *)name {
    NSString * value = [self.aliasDict objectForKey:name];
    if (value) {
        return value;
    }
    
    return name;
}

@end
