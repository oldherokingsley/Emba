//
//  NoticeTableView.m
//  SEMBA_IPAD_CLIENT_2.0
//
//  Created by 欧 展飞 on 13-10-31.
//  Copyright (c) 2013年 yaodd. All rights reserved.
//

#import "NoticeTableView.h"
#import "NoticeTableCell.h"
#define originalHeight 60.0f
#define newHeight 75.0f
#define isOpen @"didOpen"

@implementation NoticeTableView
{
    NSMutableDictionary *dicClicked;
    NSMutableDictionary *titles;
    NSMutableDictionary *titleNames;
    CGRect expandRect;
    int cellCount;
}

@synthesize titleArray;
@synthesize contentArray;
@synthesize cellArray;
@synthesize dateArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        cellCount = 5;
        
        dicClicked = [NSMutableDictionary dictionaryWithCapacity:3];
        titleNames = [[NSMutableDictionary alloc]initWithCapacity:cellCount];
        titles = [[NSMutableDictionary alloc] initWithCapacity:cellCount];
        dateArray = [[NSMutableArray alloc] initWithCapacity:cellCount];
        
        [self setData];
        
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)setData;
{
    NSString *title1 = @"通知1";
    NSString *title2 = @"通知2";
    NSString *title3 = @"通知3";
    NSString *title4 = @"通知4";
    NSString *title5 = @"通知5";
    
    NSString *date1 = @"aaaaaaaaa";
    NSString *date2 = @"aaaaaaaaa";
    NSString *date3 = @"aaaaaaaaa";
    NSString *date4 = @"aaaaaaaaa";
    NSString *date5 = @"aaaaaaaaa";
    
    NSString *content1 = @"审视我国的周边形势，周边环境发生了很大变化，我国同周边国家的关系发生了很大变化，我国同周边国家的经贸联系更加紧密、互动空前密切。这客观上要求我们的周边外交战略和工作必须与时俱进、更加主动。";
    NSString *content2 = @"近平指出，新中国成立后，以毛泽东同志为核心的党的第一代中央领导集体，以邓小平同志为核心的党的第二代中央领导集体，以江泽民同志为核心的党的第三代中央领导集体，以胡锦涛同志为总书记的党中央，都高度重视周边外交，提出了一系列重要战略思想和方针政策，开创和发展了我国总体有利的周边环境，为我们继续做好周边外交工作打下了坚实基础。党的十八大以来，党中央在保持外交大政方针延续性和稳定性的基础上，积极运筹外交全局，突出周边在我国发展大局和外交全局中的重要作用，开展了一系列重大外交活动。";
    NSString *content3 = @"使周边国家对我们更友善、更亲近、更认同、更支持，增强亲和力、感召力、影响力。要诚心诚意对待周边国家，争取更多朋友和伙伴。要本着互惠互利的原则同周边国家开展合作，编织更加紧密的共同利益网络，把双方利益融合提升到更高水平，让周边国家得益于我国发展，使我国也从周边国家共同发展中获得裨益和助力。要倡导包容的思想，强调亚太之大容得下大家共同发展，以更加开放的胸襟和更加积极的态度促进地区合作。这些理念，首先我们自己要身体力行，使之成为地区国家遵循和秉持的共同理念和行为准则。";
    NSString *content4 = @"习近平强调，我国周边外交的基本方针，就是坚持与邻为善、以邻为伴，坚持睦邻、安邻、富邻，突出体现亲、诚、惠、容的理念。发展同周边国家睦邻友好关系是我国周边外交的一贯方针。要坚持睦邻友好，守望相助；讲平等、重感情；常见面，多走动；多做得人心、暖人心的事，使周边国家对我们更友善、更亲近、更认同、更支持，增强亲和力、感召力、影响力。要诚心诚意对待周边国家，争取更多朋友和伙伴。要本着互惠互利的原则同周边国家开展合作，编织更加紧密的共同利益网络，把双方利益融合提升到更高水平，让周边国家得益于我国发展，使我国也从周边国家共同发展中获得裨益和助力。要倡导包容的思想，强调亚太之大容得下大家共同发展，以更加开放的胸襟和更加积极的态度促进地区合作。这些理念，首先我们自己要身体力行，使之成为地区国家遵循和秉持的共同理念和行为准则。";
    NSString *content5 = @"多做得人心、暖人心的事，使周边国家对我们更友善、更亲近、更认同、更支持，增强亲和力、感召力、影响力。要诚心诚意对待周边国家，争取更多朋友和伙伴。要本着互惠互利的原则同周边国家开展合作，编织更加紧密的共同利益网络，把双方利益融合提升到更高水平，让周边国家得益于我国发展，使我国也从周边国家共同发展中获得裨益和助力。要倡导包容的思想，强调亚太之大容得下大家共同发展，以更加开放的胸襟和更加积极的态度促进地区合作。这些理念，首先我们自己要身体力行，使之成为地区国家遵循和秉持的共同理念和行为准则。";
    
    self.titleArray = [[NSMutableArray alloc] initWithObjects:title1, title2, title3, title4, title5, nil];
    
    self.contentArray = [[NSMutableArray alloc] initWithObjects:content1, content2, content3, content4, content5, nil];
    
    self.dateArray = [[NSMutableArray alloc] initWithObjects:date1, date2, date3, date4, date5, nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return cellCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"cell For row %d at section %d", indexPath.row, indexPath.section);
    static NSString *contentIndentifer = @"contentIdentifier";
    
    NoticeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:contentIndentifer];
    
    if (cell == nil) {
        cell = [[NoticeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentIndentifer];
        
    }else {
        
    }
    
    cell.indexPath = indexPath;
    
    cell.title.text = [titleArray objectAtIndex:indexPath.section];
    
    cell.date.text = [dateArray objectAtIndex:indexPath.section];
    
    cell.content.text  = [contentArray objectAtIndex:indexPath.section];
    
    if ([[dicClicked objectForKey:[NSString stringWithFormat:@"%d", indexPath.section]] isEqualToString: isOpen])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0], NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName, nil];
        
        CGSize size = CGSizeMake(700, 2000);
        
        expandRect = [cell.content.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        
        cell.content.frame = CGRectMake(10, 20, 700, expandRect.size.height);
        
        
        [UIView animateWithDuration:2.0 animations:^(void){
            cell.rotateBtn.frame = CGRectMake(700, 40 + expandRect.size.height - 16, 20, 20);
        }];
        
        
        
    }else{
        cell.content.frame = CGRectMake(10, 20, 700, 16);
        [UIView animateWithDuration:2.0 animations:^(void){
            cell.rotateBtn.frame = CGRectMake(700, 40, 20, 20);
        }];
        //[cell rotateExpandBtnToCollapsed];
    }
    
    return cell;
}

//Section的标题栏高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

/*
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 
 }
 */
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row %d at Section %d was selected",indexPath.row, indexPath.section);
    
    NoticeTableCell *targetCell = (NoticeTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (targetCell.frame.size.height == originalHeight){
        
        [dicClicked setObject:isOpen forKey:[NSString stringWithFormat:@"%d", indexPath.section]];
        
        [targetCell rotateExpandBtnToExpanded];
        
    }
    else{
        [dicClicked removeObjectForKey:[NSString stringWithFormat:@"%d", indexPath.section]];
        
        [targetCell rotateExpandBtnToCollapsed];
    }
    
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Height for row %d at section %d.", indexPath.row, indexPath.section);
    
    NSString *content = [contentArray objectAtIndex:indexPath.section];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0], NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName, nil];
    
    CGSize size = CGSizeMake(700, 2000);
    
    expandRect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    if ([[dicClicked objectForKey:[NSString stringWithFormat:@"%d", indexPath.section]] isEqualToString: isOpen]){
        
        return expandRect.size.height + 40;
    }
    else{
        return originalHeight;
    }
}

@end
