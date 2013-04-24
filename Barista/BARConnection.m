//
//  BARConnection.m
//  Barista
//
//  Created by Steve Streza on 4/23/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARConnection.h"

@implementation BARConnection {
	GCDAsyncSocket *_socket;
	__weak BARServer *_server;
}

@synthesize server=_server;

+(instancetype)connectionWithIncomingSocket:(GCDAsyncSocket *)socket server:(BARServer *)server{
	return [[self alloc] initWithIncomingSocket:socket server:server];
}

-(instancetype)initWithIncomingSocket:(GCDAsyncSocket *)socket server:(BARServer *)server{
	if(self = [super init]){
		_server = server;
		_socket = socket;
		_socket.delegate = self;
		
		[self startConnection];
	}
	return self;
}

-(void)startConnection{
	[_socket readDataWithTimeout:10 tag:1];
}

#pragma mark GCDAsyncSocketDelegate

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
	_request = [BARRequest requestFromData:data];
	NSLog(@"Request: %@", _request);
	NSLog(@"-- parts:\n%@\n%@\n%@\n%@\n%@", _request.HTTPMethod, _request.URL, [_request userAgent], _request.body, _request.headerFields);
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
	NSLog(@"Some data %li", (unsigned long)partialLength);
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
	NSLog(@"Wrote");
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
	NSLog(@"Wrote some %li", partialLength);
}

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 *
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
	NSLog(@"Closed read");
}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * this delegate method will be called before the disconnect method returns.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
	NSLog(@"Disconnected");
}

@end
