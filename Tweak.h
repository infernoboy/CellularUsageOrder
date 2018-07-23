@interface PSSpecifier
@property(strong, nonatomic) NSString *identifier;
@end

@interface PSListController : UITableViewController
- (PSSpecifier *)specifier;
- (void)animatedReloadDataWithView:(id)view;
@end

@interface PSSubtitleSwitchTableCell
@end
