//
//  ASIHTTPRequest+category.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by yaodd on 13-10-30.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "ASIHTTPRequest+category.h"
#import <objc/runtime.h>

static void *myKey = (void *)@"myKey";
@implementation ASIHTTPRequest (associate)

- (NSDictionary *)myDict{
    return objc_getAssociatedObject(self, myKey);
}

- (void) setMyDict:(NSDictionary *)myDict{
    objc_setAssociatedObject(self, myKey, myDict, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end