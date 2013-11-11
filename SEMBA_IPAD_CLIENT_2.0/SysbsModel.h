//
//  SysbsModel.h
//  SYSBS_EMBA_IPAD_CLIENT
//
//  Created by 王智锐 on 11/11/13.
//  Copyright (c) 2013 yaodd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Course.h"
#import "File.h"
#import "RecommendBook.h"

@class SysbsModel;

@interface SysbsModel : NSObject

+(SysbsModel*)getSysbsModel;
-(User*)getUser;
-(void)setUser:(User*)tempUser;

@end

