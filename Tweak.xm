#import "Tweak.h"

%hook PSListController

NSArray *map;
NSInteger count, cellularSectionNumber;
NSString *cellularDataTitle;

BOOL enabled = YES;

NSString *preferencesUIPath = @"/System/Library/PrivateFrameworks/PreferencesUI.framework";

- (void)viewWillDisappear:(BOOL)animated {
    map = nil;

    %orig;
}

- (NSInteger)numberOfSectionsInTableView:(id)view {
    NSInteger result = %orig;

    if ([[self specifier].identifier isEqualToString:@"MOBILE_DATA_SETTINGS_ID"] && [self isViewLoaded] && self.view.window != nil) {
        if ([cellularDataTitle length] == 0) {
            NSBundle *stringBundle;

            NSFileManager *fileManager = [NSFileManager defaultManager];

            if ([fileManager fileExistsAtPath:preferencesUIPath]) {
                stringBundle = [NSBundle bundleWithPath:preferencesUIPath];
            } else {
                stringBundle = [NSBundle bundleWithPath:@"/Applications/Preferences.app"];
            }
            
            cellularDataTitle = [stringBundle localizedStringForKey:@"APP_DATA_USAGE" value:@"" table:@"Network~iphone"];

            stringBundle = nil;
            fileManager = nil;

            if ([[self tableView:view titleForHeaderInSection:0] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 0;
            else if ([[self tableView:view titleForHeaderInSection:1] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 1;
            else if ([[self tableView:view titleForHeaderInSection:2] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 2;
            else if ([[self tableView:view titleForHeaderInSection:3] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 3;
            else if ([[self tableView:view titleForHeaderInSection:4] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 4;
            else if ([[self tableView:view titleForHeaderInSection:5] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 5;
            else if ([[self tableView:view titleForHeaderInSection:6] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 6;
            else if ([[self tableView:view titleForHeaderInSection:7] isEqualToString:cellularDataTitle])
                cellularSectionNumber = 7;
        }
    }

    return result;
}

- (NSInteger)tableView:(UITableView *)view numberOfRowsInSection:(NSInteger)section {
    NSInteger result = %orig;

    if ([[self specifier].identifier isEqualToString:@"MOBILE_DATA_SETTINGS_ID"] && section == cellularSectionNumber && [self isViewLoaded] && self.view.window != nil) {
        count = 0;

        if (result > 1) {
            NSInteger num;
            
            if ([[self tableView:view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:result - 2 inSection:section]] isKindOfClass:[%c(PSSubtitleSwitchTableCell) class]])
                num = result - 1;
            else
                num = result - 2;

            if ([map count] == num) {
                count = num;
            } else {
                NSMutableArray *data = [NSMutableArray arrayWithCapacity:num];

                for (NSInteger i = 0; i < num; i++) {
                    float size;

                    if (![[self tableView:view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]] isKindOfClass:[%c(PSSubtitleSwitchTableCell) class]]) {
                        size = 1000000000000;
                    } else {
                        NSString *sizeString = [self tableView:view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]].detailTextLabel.text;
                                    
                        size = [sizeString floatValue];

                        NSInteger length = [sizeString length];

                        if (length > 2)
                            switch ([sizeString characterAtIndex:length - 2]) {
                                case 'M':
                                    size *= 1024;
                                    break;
                                case 'G':
                                    size *= 1024 * 1024;
                                    break;
                                case 'T':
                                    size *= 1024 * 1024 * 1024;
                            }
                        if (length > 3) {
                            switch ([sizeString characterAtIndex:length - 3]) {
                                case L'מ':
                                    size *= 1024;
                                    break;
                                case L'ג':
                                    size *= 1024 * 1024;
                            }
                        }
                    }
           
                    [data addObject:@[[NSNumber numberWithInt:i], [NSNumber numberWithInt:size]]];
                }

                map = [data sortedArrayUsingComparator:^NSComparisonResult(NSMutableArray *a, NSMutableArray *b) {
                    return [b[1] compare: a[1]];
                }];

                data = nil;

                count = num;
            }
        }
    }
    
    return result;
}

- (id)tableView:(id)view cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (enabled && indexPath.row < count && [[self specifier].identifier isEqualToString:@"MOBILE_DATA_SETTINGS_ID"] && indexPath.section == cellularSectionNumber && [self isViewLoaded] && self.view.window != nil)
        return %orig(view, [NSIndexPath indexPathForRow:[map[indexPath.row][0] intValue] inSection:indexPath.section]);
    else
        return %orig;
}

- (void)tableView:(id)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self specifier].identifier isEqualToString:@"MOBILE_DATA_SETTINGS_ID"] && indexPath.section == cellularSectionNumber && indexPath.row == 0) {
        enabled = !enabled;
        
        [view reloadData];
    }
    
    %orig;
}

%end
