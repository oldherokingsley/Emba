//
//  MyCourse.h
//  testJson
//
//  Created by 王智锐 on 13-9-21.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Course.h"
@interface MyCourse : NSObject

@property (strong,nonatomic)NSMutableArray *courseArr;

+(MyCourse *)sharedMyCourse;
-(void) addCourse:(Course *)course;
-(void) setCourses:(NSMutableArray *)arr;
-(NSMutableArray*)getMyCourse;
@end
