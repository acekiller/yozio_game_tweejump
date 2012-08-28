//
//  Copyright 2011 Yozio. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "CommonCrypto/CommonCryptor.h"
#import "FBEncryptorAES.h"
#import "NSData+Base64.h"
#import "NSString+MD5.h"
#import "JSONKit.h"
#import "Seriously.h"
#import "OpenUDID.h"

#import "Yozio.h"
#import "Yozio_Private.h"


@implementation Yozio

// User set instrumentation variables.
@synthesize _appKey;
@synthesize _secretKey;
@synthesize _async;

// Automatically determined instrumentation variables.
@synthesize deviceId;
@synthesize hardware;
@synthesize os;
@synthesize countryName;
@synthesize language;
@synthesize timezone;
@synthesize deviceName;

// Internal variables.
@synthesize dataQueue;
@synthesize dataToSend;
@synthesize dataCount;
@synthesize dateFormatter;
@synthesize config;
@synthesize stopBlocking;


/*******************************************
 * Initialization.
 *******************************************/

static Yozio *instance = nil;

+ (void)initialize
{
  if (instance == nil) {
    instance = [[self alloc] init];
  }
}

- (id)init
{
  self = [super init];
  
  // User set instrumentation variables.
  self._appKey = nil;
  self._secretKey = nil;
  
  // Initialize constant intrumentation variables.
  UIDevice* device = [UIDevice currentDevice];
  [self loadOrCreateDeviceId];
  self.hardware = device.model;
  self.os = [device systemVersion];
  self.deviceName = [device name];
  
  // Initialize  mutable instrumentation variables.
  [self updateCountryName];
  [self updateLanguage];
  [self updateTimezone];
  
  self.dataCount = 0;
  self.dataQueue = [[NSMutableArray alloc] init];
  self.dataToSend = nil;
  self.config = nil;
  
  // Initialize dateFormatter.
  NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
  NSDateFormatter *tmpDateFormatter = [[NSDateFormatter alloc] init];
  self.dateFormatter = tmpDateFormatter;
  [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
  [self.dateFormatter setTimeZone:gmt];
  [tmpDateFormatter release];
  
  // Add notification observers.
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver:self
                         selector:@selector(onApplicationWillTerminate:)
                             name:UIApplicationWillTerminateNotification
                           object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(onApplicationWillResignActive:)
                             name:UIApplicationWillResignActiveNotification
                           object:nil];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
  if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
    [notificationCenter addObserver:self
                           selector:@selector(onApplicationWillEnterForeground:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(onApplicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
  }
#endif
  
  return self;
}

// Used for testing.
+ (Yozio *)getInstance
{
  return instance;
}

+ (void)log:(NSString *)format, ...
{
  if (YOZIO_LOG) {
    va_list argList;
    va_start(argList, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    NSLog(@"%@", formatStr);
    [formatStr release];
  }
}


/*******************************************
 * Public API.
 *******************************************/

+ (void)configure:(NSString *)appKey 
        secretKey:(NSString *)secretKey 
{
  [Yozio configure:appKey secretKey:secretKey async:false];
}

+ (NSString *)getUrl:(NSString *)linkName fallbackUrl:(NSString *)fallbackUrl
{
  if (instance.config == nil) {
    return fallbackUrl;
  }
  NSString *val = [instance.config objectForKey:linkName];
  return val != nil ? val : fallbackUrl;
}

+ (void)viewedLink:(NSString *)linkName
{
  [instance doCollect:YOZIO_VIEWED_LINK_ACTION
             linkName:linkName
             maxQueue:YOZIO_ACTION_DATA_LIMIT];
}

+ (void)sharedLink:(NSString *)linkName
{
  [instance doCollect:YOZIO_SHARED_LINK_ACTION
             linkName:linkName
             maxQueue:YOZIO_ACTION_DATA_LIMIT];
}

/*******************************************
 * Notification observer methods.
 *******************************************/

- (void)onApplicationWillTerminate:(NSNotification *)notification
{
  [self saveUnsentData];
}

/*******************************************
 * Data collection helper methods.
 *******************************************/

- (BOOL)validateConfiguration
{
  BOOL validAppKey = self._appKey != nil;
  BOOL validSecretKey = self._secretKey != nil;
  if (!validAppKey || !validSecretKey) {
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    NSLog(@"Please call [Yozio configure] before instrumenting.");
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  }
  return validAppKey && validSecretKey;
}

- (void)doCollect:(NSString *)type
         linkName:(NSString *)linkName
         maxQueue:(NSInteger)maxQueue
{
  if (![self validateConfiguration]) {
    return;
  }
  dataCount++;
  if ([self.dataQueue count] < maxQueue) {
    NSMutableDictionary *d =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [self notNil:type], YOZIO_D_TYPE,
     [self notNil:linkName], YOZIO_D_LINK_NAME,
     [self notNil:[self timeStampString]], YOZIO_D_TIMESTAMP,
     [NSNumber numberWithInteger:dataCount], YOZIO_D_DATA_COUNT,
     nil];
    [self.dataQueue addObject:d];
    [Yozio log:@"doCollect: %@", d];
  }
  [self checkDataQueueSize];
}

+ (void)openedApp
{
  [instance doCollect:YOZIO_OPENED_APP_ACTION
             linkName:@""
             maxQueue:YOZIO_ACTION_DATA_LIMIT];
}

- (void)checkDataQueueSize
{
  [Yozio log:@"data queue size: %i",[self.dataQueue count]];
  // Only try to flush when the dataCount is a multiple of YOZIO_FLUSH_DATA_COUNT.
  // Use self.dataCount instead of dataQueue length because the dataQueue length can be capped.
  if (self.dataCount > 0 && self.dataCount % YOZIO_FLUSH_DATA_COUNT == 0) {
    [self doFlush];
  }
}

- (void)doFlush
{
  if ([self.dataQueue count] == 0) {
    [Yozio log:@"No data to flush."];
    return;
  }
  if (self.dataToSend != nil) {
    [Yozio log:@"Already flushing"];
    return;
  }
  if ([self.dataQueue count] > YOZIO_FLUSH_DATA_COUNT) {
    self.dataToSend = [self.dataQueue subarrayWithRange:NSMakeRange(0, YOZIO_FLUSH_DATA_COUNT)];
  } else {
    self.dataToSend = [NSArray arrayWithArray:self.dataQueue];
  }
  [Yozio log:@"Flushing..."];
  NSData *iv = [FBEncryptorAES generateIv];
  NSString *ivBase64 = [iv base64EncodedString];
  
  NSString *dataStr = [self buildPayload:iv];
  
  NSString *urlParams = [NSString stringWithFormat:@"data=%@&%@=%@&iv=%@", dataStr, YOZIO_P_APP_KEY, self._appKey, ivBase64];
  // TODO(jt): try to avoid having to escape urlParams if possible
  NSString *escapedUrlParams =
  [[urlParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
  NSString *urlString =
  [NSString stringWithFormat:@"http://%@/isdk?%@", YOZIO_TRACKING_SERVER_URL, escapedUrlParams];
  
  [Yozio log:@"Final get request url: %@", urlString];
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  [Seriously get:urlString handler:^(id body, NSHTTPURLResponse *response, NSError *error) {
    if (error) {
      [Yozio log:@"Flush error %@", error];
    } else {
      if ([response statusCode] == 200) {
        [Yozio log:@"dataQueue before remove: %@", self.dataQueue];
        [self.dataQueue removeObjectsInArray:self.dataToSend];
        [Yozio log:@"dataQueue after remove: %@", self.dataQueue];
        // TODO(jt): stop background task if running in background
      }
    }
    [Yozio log:@"flush request complete"];
    self.dataToSend = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }];
}

- (NSString *)buildPayload:(NSData *)iv
{  
  // TODO(jt): compute real digest from shared key
  NSNumber *packetCount = [NSNumber numberWithInteger:[self.dataToSend count]];
  NSMutableDictionary* payload = [NSMutableDictionary dictionary];
  [payload setObject:YOZIO_BEACON_SCHEMA_VERSION forKey:YOZIO_P_SCHEMA_VERSION];
  [payload setObject:self._appKey forKey:YOZIO_P_APP_KEY];
  [payload setObject:[self notNil:[self loadOrCreateDeviceId]] forKey:YOZIO_P_DEVICE_ID];
  [payload setObject:[self notNil:self.hardware] forKey:YOZIO_P_HARDWARE];
  [payload setObject:[self notNil:self.os] forKey:YOZIO_P_OPERATING_SYSTEM];
  [payload setObject:[self notNil:self.countryName] forKey:YOZIO_P_COUNTRY];
  [payload setObject:[self notNil:self.language] forKey:YOZIO_P_LANGUAGE];
  [payload setObject:self.timezone forKey:YOZIO_P_TIMEZONE];
  [payload setObject:self.deviceName forKey:YOZIO_P_DEVICE_NAME];
  [payload setObject:packetCount forKey:YOZIO_P_PAYLOAD_COUNT];
  [payload setObject:self.dataToSend forKey:YOZIO_P_PAYLOAD];
  [Yozio log:@"payload: %@", payload];
  
  //  JSONify
  NSString *jsonPayload = [payload JSONString];
  //  Convert to Data
  NSData *data = [jsonPayload dataUsingEncoding:NSUTF8StringEncoding];
  
  NSString* md5 = [self._secretKey MD5String];
  NSData *key = [md5 dataUsingEncoding:NSUTF8StringEncoding];
  
  //  AES Encrypt
  NSData *encryptedData = [FBEncryptorAES encryptData:data
                                                  key:key
                                                   iv:iv];
  //  Base64 encode
  NSString *base64EncryptedData = [encryptedData base64EncodedString];
  
  return base64EncryptedData;
}


- (NSString *)notNil:(NSString *)str
{
  if (str == nil) {
    return @"Unknown";
  } else {
    return str;
  }
}

- (NSDictionary *)dictNotNil:(NSDictionary *)dict
{
  if (dict == nil) {
    return [NSDictionary dictionary];
  } else {
    return dict;
  }
}

/*******************************************
 * Instrumentation data helper methods.
 *******************************************/

- (NSString *)timeStampString
{
  NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
  NSDateFormatter *tmpDateFormatter = [[NSDateFormatter alloc] init];
  self.dateFormatter = tmpDateFormatter;
  [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
  [tmpDateFormatter release];
  [self.dateFormatter setTimeZone:gmt];
  NSString *timeStamp = [self.dateFormatter stringFromDate:[NSDate date]];
  return timeStamp;
}

- (void)updateCountryName
{
  NSLocale *locale = [NSLocale currentLocale];
  NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
  self.countryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
}

- (void)updateLanguage
{
  self.language = [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (void)updateTimezone
{
  [NSTimeZone resetSystemTimeZone];
  NSInteger timezoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT]/3600;
  self.timezone = [NSNumber numberWithInteger:timezoneOffset];
}

/*******************************************
 * File system helper methods.
 *******************************************/

- (void)saveUnsentData
{
  [Yozio log:@"saveUnsentData: %@", self.dataQueue];
  if (![NSKeyedArchiver archiveRootObject:self.dataQueue toFile:YOZIO_DATA_QUEUE_FILE]) {
    [Yozio log:@"Unable to archive dataQueue!"];
  }
}

- (void)loadUnsentData
{
  if ([[NSFileManager defaultManager] fileExistsAtPath: YOZIO_DATA_QUEUE_FILE]) {
    self.dataQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:YOZIO_DATA_QUEUE_FILE];
    if (self.dataQueue == nil)  {
      self.dataQueue = [NSMutableArray array];
    }
  }
  [Yozio log:@"loadUnsentData: %@", self.dataQueue];
}



/*******************************************
 * UUID helper methods.
 *******************************************/

/**
 * Using OpenUDID to generate a unique device identifier since the native device's UDID is deprecated.
 * 
 * @return The deviceId or nil if any error occurred while loading/creating/storing the UUID.
 */

- (NSString *)loadOrCreateDeviceId
{
  self.deviceId = [OpenUDID value];
  return self.deviceId;
}


/*******************************************
 * Configuration helper methods.
 *******************************************/

+ (void)configure:(NSString *)appKey 
        secretKey:(NSString *)secretKey 
            async:(BOOL)async
{
  if (appKey == nil) {
    [NSException raise:NSInvalidArgumentException format:@"appKey cannot be nil."];
  }
  if (secretKey == nil) {
    [NSException raise:NSInvalidArgumentException format:@"secretKey cannot be nil."];
  }
  instance._appKey = appKey;
  instance._secretKey = secretKey;
  instance._async = async;
  
  [instance updateConfig];
  [Yozio openedApp];
  
  // Load any previous data and try to flush it.
  // Perform this here instead of on applicationDidFinishLoading because instrumentation calls
  // could be made before an application is finished loading.
  [instance loadUnsentData];
  [instance doFlush];
}

/**
 * Update self.configs with data from server.
 */

- (void)updateConfig
{
  if (self._appKey == nil) {
    [Yozio log:@"updateConfig nil appKey"];
    return;
  }
  if (self.deviceId == nil) {
    [Yozio log:@"updateConfig nil deviceId"];
    return;
  }
  
  
  NSMutableDictionary* payload = [NSMutableDictionary dictionary];
  [payload setObject:YOZIO_BEACON_SCHEMA_VERSION forKey:YOZIO_P_SCHEMA_VERSION];
  [payload setObject:self._appKey forKey:YOZIO_P_APP_KEY];
  [payload setObject:[self notNil:[self loadOrCreateDeviceId]] forKey:YOZIO_P_DEVICE_ID];
  [payload setObject:[self notNil:self.hardware] forKey:YOZIO_P_HARDWARE];
  [payload setObject:[self notNil:self.os] forKey:YOZIO_P_OPERATING_SYSTEM];
  [payload setObject:[self notNil:self.countryName] forKey:YOZIO_P_COUNTRY];
  [payload setObject:[self notNil:self.language] forKey:YOZIO_P_LANGUAGE];
  [payload setObject:self.timezone forKey:YOZIO_P_TIMEZONE];
  
  NSString *urlParams = [NSString stringWithFormat:@"data=%@", [payload JSONString]];
  NSString *urlString =
  [NSString stringWithFormat:@"http://%@/get_config?%@", YOZIO_CONFIGURATION_SERVER_URL, urlParams];
  NSString* escapedUrlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  [Yozio log:@"Final configuration request url: %@", escapedUrlString];
  
  if (!self._async) {
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(stopBlockingApp) userInfo:nil repeats:NO];
  }
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  //  add some timing check before and on response
  [Seriously get:escapedUrlString handler:^(id body, NSHTTPURLResponse *response, NSError *error) {
    if (error) {
      self.stopBlocking = true;
      [Yozio log:@"updateConfig error %@", error];
    } else {
      if ([response statusCode] == 200) {
        [Yozio log:@"config before update: %@", self.config];
        self.config = [body objectForKey:YOZIO_URLS_KEY];
        self.stopBlocking = true;
        [Yozio log:@"urls after update: %@", self.config];
      }
    }
    [Yozio log:@"configuration request complete"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }];
  
  // TODO(jt): look into why currentRunLoop is needed
  
  if (!self._async) {
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (!self.stopBlocking && [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:loopUntil]) {
      loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.5];
    }
  }
}

- (void)stopBlockingApp {
  self.stopBlocking = true;
}

- (void)dealloc
{
  [_appKey release], _appKey = nil;
  [_secretKey release], _secretKey = nil;
  [deviceId release], deviceId = nil;
  [dateFormatter release], dateFormatter = nil;
  [super dealloc];
}


@end
