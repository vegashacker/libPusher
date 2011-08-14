//
//  PusherEventsAppDelegate.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsAppDelegate.h"
#import "PusherEventsViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"

// this is not included in the source
// you must create this yourself and define PUSHER_API_KEY in it
#import "Constants.h" 

@implementation PusherEventsAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize eventsViewController;
@synthesize pusher = _pusher;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
  // establish a new pusher instance
  self.pusher = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self];
  
  // we want the connection to automatically reconnect if it dies
  self.pusher.reconnectAutomatically = YES;
  
  // log all events received, regardless of which channel they come from
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:nil];
  
  // pass the pusher into the events controller
  self.eventsViewController.pusher = self.pusher;

  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];
}

- (void)dealloc 
{
  [[NSNotificationCenter defaultCenter] 
    removeObserver:self name:PTPusherEventReceivedNotification object:self.pusher];
  [_pusher release];
  [navigationController release];
  [window release];
  [super dealloc];
}

#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
  NSLog(@"[pusher] Received event %@", note.object);
}

#pragma mark - PTPusherDelegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher] Connected to Pusher (socket id: %d)", connection.socketID);
}

- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher] Disconnected from Pusher");
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  NSLog(@"[pusher] Failed to connect to pusher, error: %@", error);
}

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
  NSLog(@"[pusher] Reconnecting after %d seconds...");
}

@end
