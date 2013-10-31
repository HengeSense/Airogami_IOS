//
//  AGChatChatViewController+Aided.m
//  Airogami
//
//  Created by Tianhu Yang on 10/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatChatViewController+Aided.h"

static NSString * LikedByOthersImage = @"chat_chat_liked_others.png";
static NSString * LikedByMeImage = @"chat_chat_liked_mine.png";

@implementation AGChatChatViewController (Aided)

- (void) loadMore
{
    if ([airogami isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = airogami;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        AGMessage *message = nil;
        if (messagesData.count) {
            NSBubbleData *bubbleData = [messagesData objectAtIndex:0];
            message = bubbleData.obj;
        }
        [dict setObject:plane.planeId forKey:@"planeId"];
        if (message.messageId > 0) {
            [dict setObject:message.messageId forKey:@"startId"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetMessagesForPlane object:nil userInfo:dict];
    }
    else if ([airogami isKindOfClass:[AGChain class]]){
        AGChain *chain = airogami;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        AGChainMessage *chainMessage = nil;
        if (messagesData.count) {
            NSBubbleData *bubbleData = [messagesData objectAtIndex:0];
            chainMessage = bubbleData.obj;
        }
        [dict setObject:chain.chainId forKey:@"chainId"];
        if (chainMessage) {
            [dict setObject:chainMessage.createdTime forKey:@"startTime"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetChainMessagesForChain object:nil userInfo:dict];
    }
    
}

- (void) readMessagesForPlane:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber *planeId = [dict objectForKey:@"planeId"];
    AGPlane *plane = airogami;
    if ([planeId isEqual:plane.planeId] == NO) {
        return;
    }
    //
    for (NSBubbleData *bubbleData in messagesData) {
        AGMessage *message = bubbleData.obj;
        if (message.state.intValue == AGSendStateSent) {
            if (message.messageId.longLongValue <= message.plane.lastMsgId.longLongValue) {
                bubbleData.state = AGSendStateRead;
            }
        }
        else{
            bubbleData.state = message.state.intValue;
        }
    }
    [bubbleTable refresh:[NSArray arrayWithObject:@"state"]];
}

- (void) gotMessagesForPlane:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber *planeId = [dict objectForKey:@"planeId"];
    AGPlane *plane = airogami;
    if ([planeId isEqual:plane.planeId] == NO) {
        return;
    }
    //
    NSString *action = [dict objectForKey:@"action"];
    NSAssert(action != nil, @"nil action!");
    
    NSArray *messages = [dict objectForKey:@"messages"];
    if (messages.count == 0 && [action isEqual:@"reset"] == NO) {
        return;
    }
    NSNumber *more = [dict objectForKey:@"more"];
    if (more) {
        bubbleTable.refreshable = more.boolValue;
    }
    
    int count = messages.count;
    if ([action isEqual:@"prepend"]) {
        count += messagesData.count;
    }
    AGAccount * account = [AGAppDirector appDirector].account;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (AGMessage *message in messages) {
        NSBubbleType bubbleType = BubbleTypeMine;
        if (account != message.account) {
            bubbleType = BubbleTypeSomeoneElse;
        }
        NSBubbleData *bubbleData = nil;
        if (message.type.intValue == AGMessageTypeLike) {
            NSString *name = bubbleType == BubbleTypeMine ? LikedByMeImage : LikedByOthersImage;
            bubbleData = [NSBubbleData dataWithImage:[UIImage imageNamed:name] date:message.createdTime type:bubbleType];
        }
        else if (message.type.intValue == AGMessageTypeImage){
            if (bubbleType == BubbleTypeMine) {
                bubbleData = [NSBubbleData dataWithImageKey:[message messageDataKey:YES] url:[message messageImageUrl:YES] size:message.imageSize date:message.createdTime type:bubbleType];
            }
            else{
                bubbleData = [NSBubbleData dataWithImageURL:[message messageImageUrl:YES] size:message.imageSize date:message.createdTime type:bubbleType];
            }
        }
        else{
            bubbleData = [NSBubbleData dataWithText:message.content date:message.createdTime type:bubbleType];
        }
        
        bubbleData.account = message.account;
        if (message.state.intValue == AGSendStateSent) {
            if (message.messageId.longLongValue <= message.plane.lastMsgId.longLongValue) {
                bubbleData.state = AGSendStateRead;
            }
            else{
                bubbleData.state = message.state.intValue;
            }
        }
        else{
            bubbleData.state = message.state.intValue;
        }
        bubbleData.obj = message;
        [array addObject:bubbleData];
    }
    UIBubbleTableSetDataActionEnum setDataAction = UIBubbleTableSetDataActionReset;
    if ([action isEqual:@"reset"]) {
        [messagesData removeAllObjects];
        setDataAction = UIBubbleTableSetDataActionReset;
    }
    else if ([action isEqual:@"append"]){
        setDataAction = UIBubbleTableSetDataActionAppend;
    }
    else if ([action isEqual:@"prepend"]){
        setDataAction = UIBubbleTableSetDataActionPrepend;
    }
    if (setDataAction == UIBubbleTableSetDataActionAppend) {
        [messagesData addObjectsFromArray:array];
        [bubbleTable setData:setDataAction animated:didInitialized];
    }
    else{
        [array addObjectsFromArray:messagesData];
        messagesData = array;
        [bubbleTable setData:setDataAction animated:NO];
    }
    
}

- (void) gotChainMessagesForChain:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber *chainId = [dict objectForKey:@"chainId"];
    AGChain *chain = airogami;
    if ([chainId isEqual:chain.chainId] == NO) {
        return;
    }
    //
    NSString *action = [dict objectForKey:@"action"];
    NSAssert(action != nil, @"nil action!");
    
    NSArray *chainMessages = [dict objectForKey:@"chainMessages"];
    if (chainMessages.count == 0) {
        return;
    }
    NSNumber *more = [dict objectForKey:@"more"];
    if (more) {
        bubbleTable.refreshable = more.boolValue;
    }
    
    int count = chainMessages.count;
    if ([action isEqual:@"prepend"]) {
        count += messagesData.count;
    }
    AGAccount * account = [AGAppDirector appDirector].account;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (AGMessage *chainMessage in chainMessages) {
        NSBubbleType bubbleType = BubbleTypeMine;
        if (account != chainMessage.account) {
            bubbleType = BubbleTypeSomeoneElse;
        }
        NSBubbleData *bubbleData = [NSBubbleData dataWithText:chainMessage.content date:chainMessage.createdTime type:bubbleType];
        bubbleData.account = chainMessage.account;
        bubbleData.state = AGSendStateNone;
        bubbleData.obj = chainMessage;
        [array addObject:bubbleData];
    }
    UIBubbleTableSetDataActionEnum setDataAction = UIBubbleTableSetDataActionReset;
    if ([action isEqual:@"reset"]) {
        [messagesData removeAllObjects];
        setDataAction = UIBubbleTableSetDataActionReset;
    }
    else if ([action isEqual:@"append"]){
        setDataAction = UIBubbleTableSetDataActionAppend;
    }
    else if ([action isEqual:@"prepend"]){
        setDataAction = UIBubbleTableSetDataActionPrepend;
    }
    if (setDataAction == UIBubbleTableSetDataActionAppend) {
        [messagesData addObjectsFromArray:array];
        [bubbleTable setData:setDataAction animated:didInitialized];
    }
    else{
        [array addObjectsFromArray:messagesData];
        messagesData = array;
        [bubbleTable setData:setDataAction animated:NO];
        
    }
    
}

#pragma mark - logic

-(void) send
{
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    
    AGPlane *plane = airogami;
    AGMessage *message = [managerUtils.planeManager messageForReplyPlane:plane content:inputTextView.text type:AGMessageTypeText];
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.content date:message.createdTime type:BubbleTypeMine];
    sayBubble.account = [AGAppDirector appDirector].account;
    sayBubble.state = message.state.intValue;
    sayBubble.obj = message;
    [messagesData addObject:sayBubble];
    [bubbleTable setData:UIBubbleTableSetDataActionAppend animated:didInitialized];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSendMessages object:nil userInfo:nil];
    
}

-(void) sendImages:(NSArray*)images
{
    AGPlaneManager *planeManager = [AGManagerUtils managerUtils].planeManager;
    AGPlane *plane = airogami;
    UIImage *mediumImage = [images objectAtIndex:0];
    UIImage *smallImage = [images objectAtIndex:1];
    AGMessage *message = [planeManager messageForReplyPlane:plane content:inputTextView.text imageSize:mediumImage.size];
    //
    [[SDImageCache imageCache] storeImage:mediumImage forKey:[message messageDataKey:NO]];
    [[SDImageCache imageCache] storeImage:[images objectAtIndex:1] forKey:[message messageDataKey:YES]];
    //
    NSBubbleData *sayBubble = [NSBubbleData dataWithImage:smallImage size:message.imageSize date:message.createdTime type:BubbleTypeMine];
    sayBubble.account = [AGAppDirector appDirector].account;
    sayBubble.state = message.state.intValue;
    sayBubble.obj = message;
    [messagesData addObject:sayBubble];
    [bubbleTable setData:UIBubbleTableSetDataActionAppend animated:didInitialized];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSendDataMessages object:nil userInfo:nil];
    
}

-(void) planeRemoved:(NSNotification*)notification
{
    AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
    if ([plane isEqual:airogami]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [AGMessageUtils alertMessagePlaneChanged];
    }
}

-(void) sentMessage:(NSNotification*)notification
{
    AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
    if ([plane isEqual:airogami]) {
        AGMessage *message = [notification.userInfo objectForKey:@"message"];
        
        if (message) {
            for (NSBubbleData *bubbleData in messagesData) {
                AGMessage *msg = bubbleData.obj;
                if ([msg isEqual:message]) {
                    bubbleData.state = message.state.shortValue;
                    if(message.state.shortValue != AGSendStateFailed){
                        bubbleData.date = message.createdTime;
                        [bubbleTable setData:UIBubbleTableSetDataActionReset animated:NO];
                        //
                        [[AGManagerUtils managerUtils].audioManager playSentMessage];
                    }
                    else{
                        [bubbleTable refresh:[NSArray arrayWithObject:@"state"]];
                    }
                    
                    break;
                }
            }
        }
    }
    
}

- (void) clear
{
    clearButton.enabled = NO;
    [[AGManagerUtils managerUtils].planeManager clearPlane:airogami context:nil block:^(NSError *error, id context, BOOL succeed) {
        clearButton.enabled = YES;
    }];
}
@end
