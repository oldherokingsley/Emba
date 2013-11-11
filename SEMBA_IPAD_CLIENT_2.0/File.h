//
//  File.h
//  testJson
//
//  Created by 王智锐 on 13-9-21.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Course.h"


@interface File : NSObject{
    
}

@property (strong,retain)NSString *fileName;
@property (strong,retain)NSString *filePath;
@property (nonatomic, retain)NSString *date;
@property (weak,nonatomic)Course *course;
@property (nonatomic) int cid;

+(id)alloc;
-(id)init;

@end
