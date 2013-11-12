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

@synthesize user,myCourse;

+(SysbsModel*)getSysbsModel{
    if(sharedModel == nil){
        NSLog(@"create!!!");
        sharedModel = [[SysbsModel alloc] init];
    }
    return sharedModel;
}
/*
-(User*)getUser{
    if(sharedModel == nil ){
        NSLog(@"空的");
        return nil;
    }
    return self.user;
}

-(void)setUser:(User*)tempUser{
    if(sharedModel == nil){
        return ;
    }
    NSLog(@"tempuid%d",tempUser.uid);
    self.user = tempUser;
}
*/
-(MyCourse*)getCourses{
    if(sharedModel == nil)return nil;
    return self.myCourse;
}

-(void)setCourses:(MyCourse *)tempMyCourse{
    if(sharedModel == nil){
        return;
    }
    self.myCourse = tempMyCourse;
}
 
@end
