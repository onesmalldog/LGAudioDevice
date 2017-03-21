#import "LGAudioDevice.h"
#import <CoreServices/CoreServices.h>
#import <CoreAudio/CoreAudio.h>

@implementation LGAudioDevice 

#pragma mark Input
- (NSString *)currentInputDevice {
    AudioDeviceID currentDeviceID = [self currentDeviceID_isInput:YES];
    NSString *currentDeviceName = [self deviceNameForID:currentDeviceID isInput:YES];
    return currentDeviceName;
}
- (NSArray <NSString *>*)getInputDeviceNames {
    NSArray *availableOutputDeviceIDs = [self availableDeviceIDs_isInput:YES];
    UInt32 deviceCount = (UInt32)[availableOutputDeviceIDs count];
    NSMutableArray *deviceNamesForType = [[NSMutableArray alloc] initWithCapacity:deviceCount];
    for(NSNumber *deviceIDNumber in availableOutputDeviceIDs) {
        UInt32 deviceID = [deviceIDNumber unsignedIntValue];
        NSString *deviceName = [self deviceNameForID:deviceID isInput:YES];
        
        [deviceNamesForType addObject:deviceName];
    }
    return [NSArray arrayWithArray:deviceNamesForType];
}
- (void)setInputDevice:(NSString *)name {
    AudioDeviceID deviceID = [self deviceIDForName:name isInput:YES];
    [self setDeviceByID:deviceID isInput:YES];
}

#pragma mark Output
- (NSString *)currentOutputDevice {
    AudioDeviceID currentDeviceID = [self currentDeviceID_isInput:NO];
    NSString *currentDeviceName = [self deviceNameForID:currentDeviceID isInput:NO];
    return currentDeviceName;
}
- (NSArray<NSString *> *)getOutputDeviceNames {
    NSArray *availableOutputDeviceIDs = [self availableDeviceIDs_isInput:NO];
    UInt32 deviceCount = (UInt32)[availableOutputDeviceIDs count];
    NSMutableArray *deviceNamesForType = [[NSMutableArray alloc] initWithCapacity:deviceCount];
    for(NSNumber *deviceIDNumber in availableOutputDeviceIDs) {
        UInt32 deviceID = [deviceIDNumber unsignedIntValue];
        NSString *deviceName = [self deviceNameForID:deviceID isInput:NO];
        [deviceNamesForType addObject:deviceName];
    }
    return [NSArray arrayWithArray:deviceNamesForType];
}
- (void)setOutputDevice:(NSString *)name {
    AudioDeviceID deviceID = [self deviceIDForName:name isInput:NO];
    [self setDeviceByID:deviceID isInput:NO];
}


#pragma mark Private
- (NSArray *)availableDeviceIDs_isInput:(BOOL)is  {
    UInt32 propertySize;
    AudioDeviceID devices[64];
    int devicesCount = 0;
    AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &propertySize, NULL);
    AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &propertySize, devices);
    devicesCount = (propertySize / sizeof(AudioDeviceID));
    NSMutableArray *availableOutputDeviceIDs = [[NSMutableArray alloc] initWithCapacity:devicesCount];
    for(int i = 0; i < devicesCount; ++i) {
        if (is) {
            if ([self isInputDevice:devices[i]]) {
                NSNumber *outputDeviceID = [NSNumber numberWithUnsignedInt:devices[i]];
                [availableOutputDeviceIDs addObject:outputDeviceID];
            }
        }
        else {
            if ([self isOutputDevice:devices[i]]) {
                NSNumber *outputDeviceID = [NSNumber numberWithUnsignedInt:devices[i]];
                [availableOutputDeviceIDs addObject:outputDeviceID];
            }
        }
    }
    return [NSArray arrayWithArray:availableOutputDeviceIDs];
}
- (BOOL)isInputDevice:(AudioDeviceID)deviceID {
    UInt32 propertySize = 256;
    AudioDeviceGetPropertyInfo(deviceID, 0, true, kAudioDevicePropertyStreams, &propertySize, NULL);
    BOOL isOutputDevice = (propertySize > 0);
    return isOutputDevice;
}
- (BOOL)isOutputDevice:(AudioDeviceID)deviceID {
    UInt32 propertySize = 256;
    AudioDeviceGetPropertyInfo(deviceID, 0, false, kAudioDevicePropertyStreams, &propertySize, NULL);
    BOOL isOutputDevice = (propertySize > 0);
    return isOutputDevice;
}
- (NSString *)deviceNameForID:(AudioDeviceID)deviceID isInput:(BOOL)is {
    UInt32 propertySize = 256;
    char deviceName[256];
    if (is) AudioDeviceGetProperty(deviceID, 0, true, kAudioDevicePropertyDeviceName, &propertySize, deviceName);
    else AudioDeviceGetProperty(deviceID, 0, false, kAudioDevicePropertyDeviceName, &propertySize, deviceName);
    NSString *deviceNameForID = [NSString stringWithCString:deviceName encoding:NSUTF8StringEncoding];
    return deviceNameForID;
}
- (void)setDeviceByID:(AudioDeviceID)newDeviceID isInput:(BOOL)is {
    UInt32 propertySize = sizeof(UInt32);
    if (is) AudioHardwareSetProperty(kAudioHardwarePropertyDefaultInputDevice, propertySize, &newDeviceID);
    else AudioHardwareSetProperty(kAudioHardwarePropertyDefaultOutputDevice, propertySize, &newDeviceID);
}
- (AudioDeviceID)deviceIDForName:(NSString *)requestedDeviceName isInput:(BOOL)is {
    AudioDeviceID deviceIDForName = kAudioDeviceUnknown;
    NSArray *availableOutputDeviceIDs = [self availableDeviceIDs_isInput:is];
    for(NSNumber *deviceIDNumber in availableOutputDeviceIDs) {
        UInt32 deviceID = [deviceIDNumber unsignedIntValue];
        NSString *deviceName = [self deviceNameForID:deviceID isInput:is];
        if ([requestedDeviceName isEqualToString:deviceName]) {
            deviceIDForName = deviceID;
            break;
        }
    }
    return deviceIDForName;
}
- (AudioDeviceID)currentDeviceID_isInput:(BOOL)is {
    UInt32 propertySize;
    AudioDeviceID deviceID = kAudioDeviceUnknown;
    propertySize = sizeof(deviceID);
    if (is) AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice, &propertySize, &deviceID);
    else AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &propertySize, &deviceID);
    return deviceID;
}
@end
