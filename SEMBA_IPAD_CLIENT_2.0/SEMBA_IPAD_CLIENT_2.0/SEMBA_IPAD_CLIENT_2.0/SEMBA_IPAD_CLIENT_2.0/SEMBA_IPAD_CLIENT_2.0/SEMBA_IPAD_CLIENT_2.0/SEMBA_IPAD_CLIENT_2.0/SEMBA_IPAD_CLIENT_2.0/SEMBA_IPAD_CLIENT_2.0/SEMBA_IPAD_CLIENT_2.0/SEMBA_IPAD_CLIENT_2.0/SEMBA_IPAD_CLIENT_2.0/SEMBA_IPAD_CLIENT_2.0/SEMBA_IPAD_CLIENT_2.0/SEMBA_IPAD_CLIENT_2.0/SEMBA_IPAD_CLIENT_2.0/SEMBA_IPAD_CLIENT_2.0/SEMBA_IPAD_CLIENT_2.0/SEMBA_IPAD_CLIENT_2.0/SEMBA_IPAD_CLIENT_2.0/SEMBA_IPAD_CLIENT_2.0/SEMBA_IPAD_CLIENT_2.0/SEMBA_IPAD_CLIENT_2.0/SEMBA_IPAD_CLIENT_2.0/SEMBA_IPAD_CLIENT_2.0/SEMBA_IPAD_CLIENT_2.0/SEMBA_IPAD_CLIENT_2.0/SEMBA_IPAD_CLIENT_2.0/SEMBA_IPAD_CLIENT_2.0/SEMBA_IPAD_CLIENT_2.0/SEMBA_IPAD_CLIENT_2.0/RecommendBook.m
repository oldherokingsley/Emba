//
//  RecommendBook.m
//  testJson
//
//  Created by 王智锐 on 13-9-21.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import "RecommendBook.h"

@implementation RecommendBook

@synthesize bookName,author,description,publisher,course;


+(id)alloc{
    return [super alloc];
}

-(id)init{
    if(self = [super init]){
        bookName = @"";
        author = @"";
        publisher = @"";
        description = @"";
        course = nil;
        return self;
    }
    return nil;
}
@end
