//
//    ELIRequestSerializer.m
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

#import "ELIRDFRequestSerializer.h"

#import <AFnetworking/AFNetworking.h>

@interface ELIRDFRequestSerializer () <AFURLRequestSerialization>

@end

@implementation ELIRDFRequestSerializer

- (id)init
{
    self = [super init];

    return self;
}

- (NSMutableURLRequest *)GETRequest:(NSURL*)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [request setValue:@"application/rdf+xml" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    // Hack to force virtuoso to return RDF for non browser apps
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

@end
