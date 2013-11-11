//
//  User.m
//  testJson
//
//  Created by 王智锐 on 13-9-15.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import "User.h"

@implementation User


@synthesize username,headImg,company,rank,cellNum,uid;

//static User* user;

+(id)alloc{
   return [super alloc];
}

-(id)init{
    self = [super init];
    username = @"testname";
    company = @"testcompany";
    rank = @"testrank";
    //headImage = @"testhead";
    cellNum = @"12345678910";
    uid = 0;
    return self;
}
/*
+(User *)sharedUser{
    return user;
}

+(void)setUser:(User *)newUser{
    user = newUser;
}*/



@end
