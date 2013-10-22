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

typedef enum {
    UIBubbleTableViewNormal = 0,
    UIBubbleTableViewPulling
    
}UIBubbleTableViewState;

#define kAGPulldownOffset -10.f

@interface UIBubbleTableView ()
{
    NSIndexPath *cursorIndexPath;
    int bubbleDataCount;
    UIBubbleTableViewState state;
}

@property (nonatomic, retain) NSMutableArray *bubbleSections;

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleSections = _bubbleSections;
@synthesize typingBubble = _typingBubble;
@synthesize showAvatars = _showAvatars;
@synthesize refreshable;
@synthesize indicator;

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    state = UIBubbleTableViewNormal;
    CGRect frame = CGRectMake(0, 0, 30, 30);
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.delegate = self;
    self.dataSource = self;
    
    bubbleDataCount = 0;
    self.bubbleSections = [NSMutableArray array];
    
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


-(void) setRefreshable:(BOOL)aRefreshable
{
    refreshable = aRefreshable;
    self.tableHeaderView = refreshable ? indicator : nil;
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

- (void)setData:(UIBubbleTableSetDataActionEnum)action animated:(BOOL)animated
{
    // Loading new data
    int count = 0;
    if (self.bubbleDataSource) {
        if(action == UIBubbleTableSetDataActionPrepend || action == UIBubbleTableSetDataActionAppend){
            count = [self.bubbleDataSource rowsForBubbleTable:self] - bubbleDataCount;
            if (count < 1 ) {
                return;
            }
        }
        else if (action == UIBubbleTableSetDataActionReset){
            count = [self.bubbleDataSource rowsForBubbleTable:self];
        }
        
        
        NSMutableArray *newBubbleSections;
        
        newBubbleSections = [NSMutableArray arrayWithCapacity:count];
        
        /*[bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
         NSBubbleData *bubbleData1 = (NSBubbleData *)obj1;
         NSBubbleData *bubbleData2 = (NSBubbleData *)obj2;
         
         return [bubbleData1.date compare:bubbleData2.date];
         }];*/
        NSBubbleData *data;
        NSDate *last = nil;
        if(action == UIBubbleTableSetDataActionAppend && bubbleDataCount){
            data = [self.bubbleDataSource bubbleTableView:self dataForRow:bubbleDataCount - 1];
            last = data.date;
        }
        else{
            last = [NSDate dateWithTimeIntervalSince1970:0];
        }
        //
        NSMutableArray *currentSection = nil;
        if (action == UIBubbleTableSetDataActionAppend) {
            count = [self.bubbleDataSource rowsForBubbleTable:self];
        }
        
        for (int i = action == UIBubbleTableSetDataActionAppend ? bubbleDataCount : 0; i < count; i++)
        {
            id object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSBubbleData class]]);
            data = object;
            NSTimeInterval timeInterval = [data.date timeIntervalSinceDate:last];
            
            if (timeInterval > self.snapInterval || timeInterval < -self.snapInterval)
            {
#if !__has_feature(objc_arc)
                currentSection = [[[NSMutableArray alloc] init] autorelease];
#else
                currentSection = [[NSMutableArray alloc] init];
#endif
                [newBubbleSections addObject:currentSection];
            }
            else if (currentSection == nil){
                currentSection = self.bubbleSections.lastObject;
            }
            
            [currentSection addObject:data];
            last = data.date;
        }
        
        bubbleDataCount = [self.bubbleDataSource rowsForBubbleTable:self];
        if (action == UIBubbleTableSetDataActionAppend) {
            [self.bubbleSections addObjectsFromArray:newBubbleSections];
            //[self beginUpdates];
            //[self insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(count, newBubbleSections.count)] withRowAnimation:UITableViewRowAnimationNone];
            //[self endUpdates];
            [self reloadData];
            [self scrollToBottom:animated];
        }
        else if(action == UIBubbleTableSetDataActionPrepend){
            count = newBubbleSections.count;
            [self saveSections:count rows:currentSection.count];
            [newBubbleSections addObjectsFromArray:self.bubbleSections];
            self.bubbleSections = newBubbleSections;
            
            //[self insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)] withRowAnimation:UITableViewRowAnimationNone];
            
            [self reloadData];
            [self restoreCursorIndexPath];
        }
        else if(action == UIBubbleTableSetDataActionReset)
        {
            self.bubbleSections = newBubbleSections;
            [self reloadData];
            [self scrollToBottom:animated];
        }
        
    }
    
}

- (void) refresh:(NSArray*)fields
{
    for (id cell in self.visibleCells) {
        if ([cell isKindOfClass:[UIBubbleTableViewCell class]]) {
            UIBubbleTableViewCell *bubbleTableViewCell = cell;
            for (NSString *field in fields) {
                [bubbleTableViewCell refresh:fields];
            }
        }
        
    }
    
}

- (void) setState:(UIBubbleTableViewState) aState
{
    switch (state = aState) {
        case UIBubbleTableViewNormal:
            [indicator stopAnimating];
            break;
        case UIBubbleTableViewPulling:
            [indicator startAnimating];
            break;
            
        default:
            break;
    }
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    if (refreshable == NO) {
        return;
    }
    
    if(scrollView.isDragging)
    {
        if (scrollView.contentOffset.y < kAGPulldownOffset) {
            if (state != UIBubbleTableViewPulling) {
                [self setState:UIBubbleTableViewPulling];
                
            }
        }
        else{
            if (state != UIBubbleTableViewNormal) {
                //[self setState:UIBubbleTableViewNormal];
            }
            
        }
    }
    
    if (scrollView.contentOffset.y >= 0.0f) {
        if (state == UIBubbleTableViewPulling) {
            [self setState:UIBubbleTableViewNormal];
            [self.bubbleDelegate loadMore];
        
        }
    }
    
}

#pragma mark - UITableViewDelegate implementation


#pragma mark - UITableViewDataSource implementation


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result = [self.bubbleSections count];
    if (self.typingBubble != NSBubbleTypingTypeNobody) result++;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing bubble
	if (section >= [self.bubbleSections count]) return 1;
    
    return [[self.bubbleSections objectAtIndex:section] count] + 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSections count])
    {
        return MAX([UIBubbleTypingTableViewCell height], self.showAvatars ? kAvartarHeight + kAvatarMargin : 0);
    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [UIBubbleHeaderTableViewCell height];
    }
    
    NSBubbleData *data = [[self.bubbleSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom, self.showAvatars ? kAvartarHeight + kAvatarMargin : 0) + kCellSpacing;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = nil;
    // Now typing
	if (indexPath.section >= [self.bubbleSections count])
    {
        static NSString *cellId = @"tblBubbleTypingCell";
        UIBubbleTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) cell = [[UIBubbleTypingTableViewCell alloc] init];

        cell.type = self.typingBubble;
        cell.showAvatar = self.showAvatars;
        tableViewCell = cell;
    }
    else if (indexPath.row == 0) // Header with date and time
    {
        static NSString *cellId = @"tblBubbleHeaderCell";
        UIBubbleHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        NSBubbleData *data = [[self.bubbleSections objectAtIndex:indexPath.section] objectAtIndex:0];
        
        if (cell == nil) cell = [[UIBubbleHeaderTableViewCell alloc] init];

        cell.date = data.date;
        tableViewCell = cell;
    }
    else{// Standard bubble
        static NSString *cellId = @"tblBubbleCell";
        UIBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        NSBubbleData *data = [[self.bubbleSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
        
        if (cell == nil) cell = [[UIBubbleTableViewCell alloc] init];
        
        cell.showAvatar = self.showAvatars;
        cell.data = data;
        cell.bubbleTableView = self;
        tableViewCell = cell;
    }
    
    return tableViewCell;
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
    //[self reloadToBottom:YES];
}

- (void) scrollToBottom:(BOOL)animated
{
    int section = [self numberOfSections] - 1;
    if (section > -1) {
        int row = [self numberOfRowsInSection:section] - 1;
        if (row > -1) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            [self scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
       
    }
    
    
}

- (void) saveSections:(int)sections rows:(int)rows
{
    cursorIndexPath = [NSIndexPath indexPathForRow:0 inSection:sections];
}

- (void) restoreCursorIndexPath
{
    [self scrollToRowAtIndexPath:cursorIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGPoint point = self.contentOffset;
    point.y -= self.tableHeaderView.frame.size.height;
    self.contentOffset = point;
}

@end
