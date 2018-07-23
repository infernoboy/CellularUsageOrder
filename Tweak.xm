#import "Tweak.h"

%hook PSListController

NSArray *map;
NSInteger count, cellularSectionNumber;
NSString *cellularDataTitle;

BOOL enabled = YES;
BOOL didLoadStrings = NO;

- (NSInteger)numberOfSectionsInTableView:(id)view {
    NSInteger result = %orig;

    if ([[self specifier].identifier isEqualToString:@"MOBILE_DATA_SETTINGS_ID"]) {
        if (!didLoadStrings) {            
            didLoadStrings = YES;

            NSBundle *preferencesUI = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/PreferencesUI.framework"];
            
            cellularDataTitle = [preferencesUI localizedStringForKey:@"APP_DATA_USAGE" value:@"" table:@"Network~iphone"];

            preferencesUI = nil;
        }

        if ([[self tableView:view titleForHeaderInSection:0] isEqualToString:cellularDataTitle])
            cellularSectionNumber = 0;
        else if ([[self tableView:view titleForHeaderInSection:1] isEqualToString:cellularDataTitle])
            cellularSectionNumber = 1;
        else if ([[self tableView:view titleForHeaderInSection:2] isEqualToString:cellularDataTitle])
            cellularSectionNumber = 2;
        else if ([[self tableView:view titleForHeaderInSection:3] isEqualToString:cellularDataTitle])
            cellularSectionNumber = 3;
    }

    return result;
}

- (NSInteger)tableView:(id)view numberOfRowsInSection:(NSInteger)section {
    NSInteger result = %orig;

    if ([[self specifier].identifier isEqualToString:@"MOBILE_DATA_SETTINGS_ID"] && section == cellularSectionNumber) {
        count = 0;

        if (result > 1) {
            NSInteger num;
            
            if ([[self tableView:view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:result - 2 inSection:section]] isKindOfClass:[%c(PSSubtitleSwitchTableCell) class]])
                num = result - 1;
            else
                num = result - 2;

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
       
                [data addObject:[[Entry alloc] initWithIndex:i data:@(size)]];
            }

            map = [data sortedArrayUsingComparator:^NSComparisonResult(Entry *a, Entry *b) {
                return [b.data compare: a.data];
            }];

            count = num;
        }
    }
    
    return result;
}

- (id)tableView:(id)view cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (enabled && indexPath.row < count && [[self specifier].identifier isEqualToString:@"MOBILE_DATA_SETTINGS_ID"] && indexPath.section == cellularSectionNumber)
        return %orig(view, [NSIndexPath indexPathForRow:((Entry *)map[indexPath.row]).index inSection:indexPath.section]);
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
