//
//  MyCourse.m
//  testJson
//
//  Created by 王智锐 on 13-9-21.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import "MyCourse.h"

@interface MyCourse (PRIVATE)

@property (strong,nonatomic)NSMutableArray *courseArr;

@end

@implementation MyCourse (PRIVATE)


@end

@implementation MyCourse


//static MyCourse *mMyCourse = nil;

/*
+(MyCourse *)sharedMyCourse{
    if(mMyCourse == nil){
        mMyCourse = [[self alloc] init];
    }
    return mMyCourse;
}*/

-(void)addCourse:(Course *)course{
    [self.courseArr addObject:course];
}

-(void)setCourses:(NSMutableArray *)arr{
    self.courseArr = arr;
}

-(NSArray *)getMyCourse{
    return self.courseArr;
}



@end
