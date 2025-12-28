//
//  ApplicationSettings.h
//  NetworkMIDI
//

#import <Foundation/Foundation.h>


@interface ApplicationSettings : NSObject

@property (nonatomic, strong) NSNumber* midiChannel;

+ (ApplicationSettings*) sharedInstance;

@end
