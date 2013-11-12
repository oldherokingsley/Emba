//
//  SysbsModel.m
//  SYSBS_EMBA_IPAD_CLIENT
//
//  Created by 王智锐 on 11/11/13.
//  Copyright (c) 2013 yaodd. All rights reserved.
//

#import "SysbsModel.h"


@implementation SysbsModel

static SysbsModel* sharedModel = nil;
User *user;
MyCourse *myCourse;


+(SysbsModel*)getSysbsModel{
    if(sharedModel == nil){
        NSLog(@"create!!!");
        sharedModel = [[SysbsModel alloc] init];
    }
    return sharedModel;
}

-(User*)getUser{
    if(sharedModel == nil ){
        NSLog(@"空的");
        return nil;
    }
    return sharedModel.user;
}

-(void)setUser:(User*)tempUser{
    if(sharedModel == nil){
        return ;
    }
    self.user = tempUser;
}

-(MyCourse*)getMyCourse{
    if(sharedModel == nil)return nil;
    return self.myCourse;
}

-(void)setMyCourse:(MyCourse *)tempMyCourse{
    if(sharedModel == nil){
        return;
    }
    self.myCourse = tempMyCourse;
}
@end
