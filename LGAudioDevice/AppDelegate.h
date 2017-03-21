#import <Foundation/Foundation.h>

@interface LGAudioDevice : NSObject

/**
 Get current device name

 @return it can't be nil
 */
- (NSString *)currentOutputDevice;
- (NSString *)currentInputDevice;

/**
 Set input or output device

 @param name name of device
 */
- (void)setOutputDevice:(NSString *)name;
- (void)setInputDevice:(NSString *)name;

/**
 Get all devices name

 @return value is array, contains name of device
 */
- (NSArray <NSString *>*)getOutputDeviceNames;
- (NSArray <NSString *>*)getInputDeviceNames;
@end
