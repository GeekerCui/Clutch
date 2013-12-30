#import "CAApplicationsController.h"



NSArray * get_application_list(BOOL sort) {
    
    
    NSMutableArray *returnArray = [NSMutableArray new];
    
    NSDictionary* options = @{@"ApplicationType":@"User",@"ReturnAttributes":@[@"CFBundleShortVersionString",@"CFBundleVersion",@"Path",@"CFBundleDisplayName"]};
    
    NSDictionary *installedApps = MobileInstallationLookup(options);
    
    for (NSString *bundleID in [installedApps allKeys]) {
        
        NSDictionary *appI=[installedApps objectForKey:bundleID];
        
        NSString *appPath=[[appI objectForKey:@"Path"]stringByAppendingString:@"/"];
        
        NSString *container=[[appPath stringByDeletingLastPathComponent]stringByAppendingString:@"/"];
        
        NSString *scinfo=[appPath stringByAppendingPathComponent:@"SC_Info"];
        
        NSString *displayName=[appI objectForKey:@"CFBundleDisplayName"];
        
        if (displayName==nil) {
            displayName=[[appPath lastPathComponent]stringByReplacingOccurrencesOfString:@".app" withString:@""];
        }
        
        NSString *version=@"";
        
        if ([[appI allKeys]containsObject:@"CFBundleShortVersionString"]) {
            version=[appI objectForKey:@"CFBundleShortVersionString"];
        }else{
            version=[appI objectForKey:@"CFBundleVersion"];
        }
        
        BOOL yrn=YES;
        
        BOOL scinfoExist = [[NSFileManager defaultManager]fileExistsAtPath:scinfo isDirectory:&yrn];
        
        if (scinfoExist)
        {
            CAApplication *app=[[CAApplication alloc]initWithAppInfo:@{@"ApplicationBaseDirectory":container,@"ApplicationDirectory":appPath,@"ApplicationDisplayName":displayName,@"ApplicationName":[[appPath lastPathComponent]stringByReplacingOccurrencesOfString:@".app" withString:@""],@"RealUniqueID":[container lastPathComponent],@"ApplicationBasename":[appPath lastPathComponent],@"ApplicationVersion":version,@"ApplicationBundleID":bundleID}];
            
            [returnArray addObject:app];
        }
    }
	
	if ([returnArray count] == 0)
		return nil;
	
    if (sort) {
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                    initWithKey:@"applicationName"
                                    ascending:YES
                                    selector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
        [returnArray sortUsingDescriptors:sortDescriptors];
    }
    
	return (NSArray *) returnArray;
}

@implementation CAApplicationsController

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static CAApplicationsController* shared = nil;
    dispatch_once(&pred, ^{
        shared = [CAApplicationsController new];
    });
    return shared;
}

- (NSArray *)installedApps
{
    return get_application_list(YES);
}

- (NSArray *)crackedApps
{
    NSString *crackedPath = @"/var/root/Documents/Cracked";
    NSArray *array=[[NSArray alloc]initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:crackedPath error:nil]];
    NSMutableArray *paths=[[NSMutableArray alloc]init];
    for (int i=0; i<array.count; i++) {
        if (![[array[i] pathExtension] caseInsensitiveCompare:@"ipa"])
            [paths addObject:array[i]];
    }
    return [paths copy];
}

@end



