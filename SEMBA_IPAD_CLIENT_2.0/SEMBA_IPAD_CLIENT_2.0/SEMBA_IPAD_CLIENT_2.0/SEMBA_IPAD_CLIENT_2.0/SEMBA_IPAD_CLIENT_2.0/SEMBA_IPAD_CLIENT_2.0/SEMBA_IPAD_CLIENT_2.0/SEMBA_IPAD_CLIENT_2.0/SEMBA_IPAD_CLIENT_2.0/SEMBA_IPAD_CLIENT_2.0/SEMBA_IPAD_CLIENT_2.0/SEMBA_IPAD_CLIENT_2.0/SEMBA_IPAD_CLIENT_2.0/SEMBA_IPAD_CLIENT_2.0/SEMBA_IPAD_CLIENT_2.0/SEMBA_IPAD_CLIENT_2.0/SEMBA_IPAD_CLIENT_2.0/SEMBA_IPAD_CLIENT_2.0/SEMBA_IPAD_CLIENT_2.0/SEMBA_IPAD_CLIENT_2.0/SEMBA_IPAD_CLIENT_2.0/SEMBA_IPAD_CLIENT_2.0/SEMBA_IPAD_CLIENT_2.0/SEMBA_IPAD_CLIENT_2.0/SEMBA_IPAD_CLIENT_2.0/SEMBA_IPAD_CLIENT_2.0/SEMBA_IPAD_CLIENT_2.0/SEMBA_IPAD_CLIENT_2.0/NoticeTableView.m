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
#define kTitleKey @"title"
#define kContentKey @"content"
#define kDateKey @"date"

@implementation NoticeTableView
{
    NSMutableDictionary *dicClicked;
    NSMutableDictionary *titles;
    NSMutableDictionary *titleNames;
    CGRect expandRect;
    int cellCount;

    int flag;
}

@synthesize dataArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        cellCount = 5;
        
        dicClicked = [NSMutableDictionary dictionaryWithCapacity:3];
        titleNames = [[NSMutableDictionary alloc]initWithCapacity:cellCount];
        titles = [[NSMutableDictionary alloc] initWithCapacity:cellCount];
        
        self.delegate = self;
        self.dataSource = self;
        
        flag = 0;
        
    }
    return self;
}



//set the presented content of tableView
- (void)setTableViewData:(NSMutableArray *)data
{
    self.dataArray = data;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"numberOfSections:%d", self.dataArray.count);
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"cell For row %d at section %d", indexPath.row, indexPath.section);
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d",[indexPath section],[indexPath row]]; //以indexPath来唯一确定cell,不使用完全重用机制
    
    NoticeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[NoticeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        flag++;
    }
    
    DataItem *item = [dataArray objectAtIndex:indexPath.section];
    
    cell.indexPath = indexPath;
    
    cell.title.text = item.title;
    
    cell.date.text = item.date;
    
    cell.content.text  = item.content;
    
    
    if ([[dicClicked objectForKey:[NSString stringWithFormat:@"%d", indexPath.section]] isEqualToString: isOpen])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0], NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName, nil];
        
        CGSize size = CGSizeMake(700, 2000);
        
        expandRect = [cell.content.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        
        cell.content.frame = CGRectMake(10, 20, 700, expandRect.size.height);
        
        cell.rotateBtn.frame = CGRectMake(700, 40, 20, 20);
        [UIView animateWithDuration:0.5 animations:^(void){
            cell.rotateBtn.frame = CGRectMake(700, 40 + expandRect.size.height - 16, 20, 20);
        }];
        
        [cell rotateExpandBtnToExpanded];
        
        
    }else{
        
        cell.content.frame = CGRectMake(10, 20, 700, 16);
        if(dataArray.count < flag)
        cell.rotateBtn.frame = CGRectMake(700, 40 + expandRect.size.height - 16, 20, 20);
        [UIView animateWithDuration:0.5 animations:^(void){
            cell.rotateBtn.frame = CGRectMake(700, 40, 20, 20);
        }];
        
        [cell rotateExpandBtnToCollapsed];
    }
    
    return cell;
}

- (void)reloadData
{
    [super reloadData];
    flag = 0;
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
        

        
    }
    else{
        [dicClicked removeObjectForKey:[NSString stringWithFormat:@"%d", indexPath.section]];
        

    }
    
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Height for row %d at section %d.", indexPath.row, indexPath.section);
    
    
    DataItem *item = [dataArray objectAtIndex:indexPath.section];
    
    NSString *content = item.content;
    
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
