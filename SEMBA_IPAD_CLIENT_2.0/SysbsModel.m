//
//  SysbsModel.m
//  SYSBS_EMBA_IPAD_CLIENT
//
//  Created by 王智锐 on 11/11/13.
//  Copyright (c) 2013 yaodd. All rights reserved.
//

#import "SysbsModel.h"

@interface SysbsModel (PRIVATEMETHOD)

@property (strong,nonatomic)User *user;
@property (strong,nonatomic)NSArray *myCourse;

@end

@implementation SysbsModel (PRIVATEMETHOD)

static SysbsModel* sharedModel = nil;


@end

@implementation SysbsModel

+(SysbsModel*)getSysbsModel{
    if(sharedModel == nil){
        sharedModel = [[SysbsModel alloc] init];
    }
    return sharedModel;
}

-(User*)getUser{
    return self.user;
}

-(void)setUser:(User *)tempUser{
    self.user = tempUser;
}

@end
