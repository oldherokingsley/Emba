//
//  RecommendBook.h
//  testJson
//
//  Created by 王智锐 on 13-9-21.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Course.h"
@interface RecommendBook : NSObject{
    
}

@property (strong,nonatomic)NSString *bookName;
@property (strong,nonatomic)NSString *author;
@property (strong,nonatomic)NSString *publisher;
@property (strong,nonatomic)NSString *description;
@property (weak,nonatomic)Course *course;

+(id)alloc;
-(id)init;
@end
