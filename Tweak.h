@interface PSSpecifier
@property(strong, nonatomic) NSString *identifier;
@end

@interface PSListController : UITableViewController
- (PSSpecifier *)specifier;
@end

@interface PSSubtitleSwitchTableCell
@end
