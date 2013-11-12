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
@property (strong,nonatomic)MyCourse *myCourse;

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
    if(sharedModel == nil)return nil;
    return self.user;
}

-(void)setUser:(User*)tempUser{
    if(sharedModel != nil){
        return ;
    }
    self.user = tempUser;
}

-(MyCourse*)getMyCourse{
    if(sharedModel == nil)return nil;
    return self.myCourse;
}

-(void)setMyCourse:(MyCourse *)tempMyCourse{
    if(sharedModel != nil){
        return;
    }
    self.myCourse = tempMyCourse;
}
@end
