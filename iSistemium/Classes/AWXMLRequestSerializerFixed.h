//
//  AWXMLRequestSerializerFixed.h
//

#import "AWSURLRequestSerialization.h"

@interface AWXMLRequestSerializerFixed : AWSXMLRequestSerializer

- (BOOL)__serializeRequest:(NSMutableURLRequest *)request headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters error:(NSError * __autoreleasing *)error;

@end
