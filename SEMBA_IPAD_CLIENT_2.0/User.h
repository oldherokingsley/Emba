//
//  User.h
//  testJson
//
//  Created by 王智锐 on 13-9-15.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject{
    
}

//+(User *)sharedUser;
+(id)alloc;
-(id)init;
//+(void)setUser:(User*)user;

@property (nonatomic)int uid;
@property (strong,nonatomic)NSString *username;
@property (strong,nonatomic)NSString *company;
@property (strong,nonatomic)NSString *rank;
@property (strong,nonatomic)UIImage *headImg;
@property (strong,nonatomic)NSString *cellNum;
@end
