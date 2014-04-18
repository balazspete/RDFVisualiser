//
//  ELIRDFResponseSerialiser.m
//  RDFVisualiser
//
//  Created by Balázs Pete on 18/04/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIRDFResponseSerialiser.h"
#import <Redland-ObjC.h>
#import <AFNetworking/AFNetworking.h>

@interface ELIRDFResponseSerialiser () <AFURLResponseSerialization>

@property RedlandStorage *storage;

@end

@implementation ELIRDFResponseSerialiser

- (id)init
{
    self = [super init];
    self.storage = [RedlandStorage new];

    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:[@200 unsignedIntegerValue]];
    self.acceptableContentTypes = [NSSet setWithObject:@"application/rdf+xml"];
    
    return self;
}


- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    NSLog(@"%@", [response.allHeaderFields objectForKey:@"Content-Type"]);


    return YES;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    // instantiate and parse the model
    
    RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
    RedlandURI *uri = [RedlandURI URIWithURL:response.URL];
    RedlandModel *model = [RedlandModel modelWithStorage:self.storage];
    
    // parse
    @try
    {
        NSLog(@"HERE!!");
        [parser parseData:data intoModel:model withBaseURI:uri];
        NSLog(@"HERE!!!!!");
        return model;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Failed to parse RDF: %@", [exception reason]]);
        return nil;
    }
}

@end
