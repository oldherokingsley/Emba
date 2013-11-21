//
//  File.m
//  testJson
//
//  Created by 王智锐 on 13-9-21.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import "File.h"

@implementation File

@synthesize fileName,filePath,course,date,cid;

+(id)alloc{
    return [super alloc];
}
-(id)init{
    if(self = [super init]){
        filePath = @"";
        fileName = @"";
        date = @"";
        course = nil;
        cid = 0;
        return self;
    }
    return nil;
}

@end
