//
//  UIBubbleTableView.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "UIBubbleHeaderTableViewCell.h"
#import "UIBubbleTypingTableViewCell.h"

@interface UIBubbleTableView ()
{
    NSIndexPath *cursorIndexPath;
}

@property (nonatomic, retain) NSMutableArray *bubbleSection;

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleSection = _bubbleSection;
@synthesize typingBubble = _typingBubble;
@synthesize showAvatars = _showAvatars;
@synthesize cursorBubbleData;
@synthesize scrollViewDelegate;

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    self.delegate = self;
    self.dataSource = self;
    
    // UIBubbleTableView default properties
    
    self.snapInterval = 120;
    self.typingBubble = NSBubbleTypingTypeNobody;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_bubbleSection release];
	_bubbleSection = nil;
	_bubbleDataSource = nil;
    [super dealloc];
}
#endif

#pragma mark - Override

- (void)reloadData
{
    // Cleaning up
	self.bubbleSection = nil;
    
    // Loading new data
    int count = 0;
#if !__has_feature(objc_arc)
    self.bubbleSection = [[[NSMutableArray alloc] init] autorelease];
#else
    self.bubbleSection = [[NSMutableArray alloc] init];
#endif
    
    if (self.bubbleDataSource && (count = [self.bubbleDataSource rowsForBubbleTable:self]) > 0)
    {
#if !__has_feature(objc_arc)
        NSMutableArray *bubbleData = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
#else
        NSMutableArray *bubbleData = [[NSMutableArray alloc] initWithCapacity:count];
#endif
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSBubbleData class]]);
            [bubbleData addObject:object];
        }
        
        /*[bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             NSBubbleData *bubbleData1 = (NSBubbleData *)obj1;
             NSBubbleData *bubbleData2 = (NSBubbleData *)obj2;
             
             return [bubbleData1.date compare:bubbleData2.date];            
         }];*/
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        
        for (int i = 0; i < count; i++)
        {
            NSBubbleData *data = (NSBubbleData *)[bubbleData objectAtIndex:i];
            NSTimeInterval timeInterval = [data.date timeIntervalSinceDate:last];
            
            if (timeInterval > self.snapInterval || timeInterval < -self.snapInterval)
            {
#if !__has_feature(objc_arc)
                currentSection = [[[NSMutableArray alloc] init] autorelease];
#else
                currentSection = [[NSMutableArray alloc] init];
#endif
                [self.bubbleSection addObject:currentSection];
            }
            
            [currentSection addObject:data];
            last = data.date;
            //
            if (data == cursorBubbleData) {
                cursorIndexPath = [NSIndexPath indexPathForRow:currentSection.count - 1 inSection:self.bubbleSection.count - 1];
            }
        }
    }
    
    [super reloadData];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    [scrollViewDelegate scrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result = [self.bubbleSection count];
    if (self.typingBubble != NSBubbleTypingTypeNobody) result++;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing bubble
	if (section >= [self.bubbleSection count]) return 1;
    
    return [[self.bubbleSection objectAtIndex:section] count] + 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        return MAX([UIBubbleTypingTableViewCell height], self.showAvatars ? kAvartarHeight + kAvatarMargin : 0);
    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [UIBubbleHeaderTableViewCell height];
    }
    
    NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom, self.showAvatars ? kAvartarHeight + kAvatarMargin : 0) + kCellSpacing;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        static NSString *cellId = @"tblBubbleTypingCell";
        UIBubbleTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) cell = [[UIBubbleTypingTableViewCell alloc] init];

        cell.type = self.typingBubble;
        cell.showAvatar = self.showAvatars;
        
        return cell;
    }

    // Header with date and time
    if (indexPath.row == 0)
    {
        static NSString *cellId = @"tblBubbleHeaderCell";
        UIBubbleHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:0];
        
        if (cell == nil) cell = [[UIBubbleHeaderTableViewCell alloc] init];

        cell.date = data.date;
       
        return cell;
    }
    
    // Standard bubble    
    static NSString *cellId = @"tblBubbleCell";
    UIBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    
    if (cell == nil) cell = [[UIBubbleTableViewCell alloc] init];
    
    cell.showAvatar = self.showAvatars;
    cell.data = data;
    return cell;
}

- (void) didSelectCellAtIndexPath:(NSIndexPath *)indexPath bubbleData:(NSBubbleData*)bubbleData type:(UIBubbleTableViewCellSelectType)type
{
    [self.bubbleDelegate bubbleTableView:self didSelectCellAtIndexPath:indexPath bubbleData:bubbleData type:type];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) reloadToBottom
{
    [self reloadToBottom:YES];
}

- (void) reloadToBottom:(BOOL)animated
{
    [self reloadData];
    int section = [self numberOfSections] - 1;
    int row = [self numberOfRowsInSection:section] - 1;
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
    
    [self scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    
}

- (void) reloadToCursor:(BOOL) animated
{
    [self reloadData];
    [self scrollToRowAtIndexPath:cursorIndexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

@end
