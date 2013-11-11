//
//  Dao.h
//  testJson
//
//  Created by 王智锐 on 13-9-13.
//  Copyright (c) 2013年 王智锐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

//直接引用SysbsModel作为model，调用sysbsmodel下方法访问属性。

//坑爹写法。。。
#define LOGIN_PASSWORD_ERROR  -1
#define LOGIN_NETWORK_ERROR  0
#define KEY_CHANGE_PASSWORD_ERROR  -1
#define KEY_CHANGE_NETWORD_ERROR  0


@interface Dao : NSObject <NSURLConnectionDataDelegate>{
//    static Dao* dao;

}


@property  BOOL reachbility;
@property (strong,nonatomic) NSJSONSerialization * jsonReader;
@property (strong,nonatomic) NSMutableData *receiveData;


+(id)sharedDao;

//登陆（完成）
-(NSData *)requestData:(NSString *)url dict:(NSDictionary *)dict filename:(NSString*)filename;
//
+(void)initNetworkStateObserver;
-(void)reachabilityChanged:(NSNotification*)note;

//返回值大部分都会设计成int。1 for 成功 0 for 联网成功获取失败（） -1 for联网失败


-(BOOL)detectNetState;
/**签到接口
 *返回   
 *  1   代表成功
 *  0   代表联网失败
 *  -1  代表已签到，不要重复签到
 *  -2  代表签到失败，服务器出错
 */
-(int)requestForCheckIn:(NSString*)uid;
/**获取签到历史接口
 *返回
 *  1   代表成功，数据结构
 *  0   代表联网失败
 *  -1  获取失败,服务器出错。
 */
-(int)requestForCheckInHistory:(NSString*)uid;
/**登录接口
 *返回
 *  1   代表登陆成功
 *  0   代表联网失败
 *  -1  代表密码出错
 *  -2  代表数据库不存在该用户 （后端还没实现）
 */
-(int)requestForLogin:(NSString*)username password:(NSString*)passwd;
/** 修改密码接口
 *返回
 *  1   代表成功修改密码
 *  0   代表联网失败
 *  -1  代表密码出错
 *  -2  代表服务器出错
 */
-(int)requestForChangePasswd:(NSString *)oldPasswd NewPassword:(NSString*)newPassword;
/**
//获取欢迎页
 *暂时废弃。
 **/
//-(WelcomePageResult *)requestForWelcomeImage;

 /** 获取我的课程
  *返回
  * 1   代表成功获取 通过getModel可获取
  * 0   代表联网失败
  * -1  代表服务器出错
  **/
-(int)requestForMyCourse:(int)uid;

/** 获取文件列表
 *返回
 * 1   代表成功获取 通过getModel可获取
 * 0   代表联网失败
 * -1  代表服务器出错
 **/
//获取文件列表
-(int)requestForFileList:(int)cid;
/**暂时废弃
//获取单个文件
-(id)requestForAFile:(int)fid UserId:(int)uid;
//获取头像
-(id)requestForHeadImage:(int)uid;
//获取推荐书目
-(RecommendBookResult *)requestForRecommend:(int)cid;
**/

/** 获取课程时间
 *返回
 * 1   代表成功获取 通过getModel可获取
 * 0   代表联网失败
 * -1  代表服务器出错
 **/
 //获取课程时间
-(BOOL)requestForCourseDate:(int)cid;
//获取最新文件
/** 获取最新文件
 *返回
 * 1   代表成功获取 通过getModel可获取
 * 0   代表联网失败
 * -1  代表服务器出错
 **/
-(int)requestForNewestFile :(int)uid;
//
/** 评教接口
 *返回
 * 1   代表成功
 * 0   代表联网失败
 * -1  代表服务器出错
 **/

-(int)requestForUpEvaluation:(NSDictionary*)dict;
/** 获取评教列表
 *返回
 * 1   代表成功获取 通过getModel可获取
 * 0   代表联网失败
 * -1  代表服务器出错
 **/

-(NSMutableArray*)requestForEvaluationList:(int)uid;
//
//-(NSString *) requestForName:(int)tid;
-(void)reachabilityChanged:(NSNotification*)note;

@end
