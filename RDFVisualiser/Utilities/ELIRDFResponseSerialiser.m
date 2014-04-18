//
//    ELIResponseSerializer.m
//    RDFVisualiser
//
//    Copyright 2014 Balazs Pete <balazs@eliendrae.net>
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
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
