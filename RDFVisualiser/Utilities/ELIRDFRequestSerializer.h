//
//  ELIRDFRequestSerializer.h
//  RDFVisualiser
//
//  Created by Balázs Pete on 18/04/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "AFURLRequestSerialization.h"

@interface ELIRDFRequestSerializer : AFHTTPRequestSerializer

- (NSMutableURLRequest *)GETRequest:(NSURL*)URL;

@end
