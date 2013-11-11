//
//  MyCourse.m
//  testJson
//
//  Created by 王智锐 on 13-9-21.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import "MyCourse.h"



@implementation MyCourse

@synthesize courseArr;

static MyCourse *mMyCourse = nil;


+(MyCourse *)sharedMyCourse{
    if(mMyCourse == nil){
        mMyCourse = [[self alloc] init];
    }
    return mMyCourse;
}

-(void)addCourse:(Course *)course{
    [courseArr addObject:course];
}

-(void)setCourses:(NSMutableArray *)arr{
    courseArr = arr;
}

-(NSMutableArray *)getMyCourse{
    return courseArr;
}



@end
