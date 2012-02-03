#import "ComboBoxDS.h"

/* for this example to work, the class must be set as:
 - data source for the table view
 - data source for the combo box
 - delegate for the table view */

@implementation ComboBoxDS

/* create, randomly initialize and release the data structure for the data source
 we'll store the data in an array, each line is a dictionary with 3 entries:
 - pos contains the line number (just an ordinary column)
 - combo contains the current selection for the combo column
 - combov contains an array with the values for the list */

-(id)init
{
    self = [super init];
    if(self)
        records = [[NSMutableArray arrayWithCapacity:25] retain];
    return self;
}

-(void)dealloc
{
    [records release];
    [super dealloc];
}

-(void)awakeFromNib
{
    srand([[NSDate date] timeIntervalSince1970]);
    int l = rand()/(int)(((unsigned)RAND_MAX + 1) / 25);
    int i, j;
    for(i = 0;i < l;i++)
    {
        int r = rand()/(int)(((unsigned)RAND_MAX + 1) / 15) + 1;
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:r];
        for(j = 0;j < r;j++)
            [list addObject:[NSString stringWithFormat:@"data %d from line %d",j,i]];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
        [dic setObject:[NSNumber numberWithInt:i] forKey:@"pos"];
        [dic setObject:list forKey:@"combov"];
        [dic setObject:[list objectAtIndex:0] forKey:@"combo"];
        [records addObject:dic];
    }
}

/* data source for the NSComboBoxCell
 it reads the data from the representedObject
 the cell is responsible to display and manage the list of options
 (we set representedObject in tableView:willDisplayCell:forTableColumn:row:)
 this is optional, the alternative is to enter a list of values in interface builder */

-(id)comboBoxCell:(NSComboBoxCell*)cell objectValueForItemAtIndex:(int)index
{
    NSArray *values = [cell representedObject];
    if(values == nil)
        return @"";
    else
        return [values objectAtIndex:index];
}

-(int)numberOfItemsInComboBoxCell:(NSComboBoxCell*)cell
{
    NSArray *values = [cell representedObject];
    if(values == nil)
        return 0;
    else
        return [values count];
}

-(int)comboBoxCell:(NSComboBoxCell*)cell indexOfItemWithStringValue:(NSString*)st
{
    NSArray *values = [cell representedObject];
    if(values == nil)
        return NSNotFound;
    else
        return [values indexOfObject:st];
}

/* data source for the NSTableView
 the table is responsible to display and record the user selection
 (as opposed to the list of choices)
 this is required */

-(int)numberOfRowsInTableView:(NSTableView*)tableView
{
    return [records count];
}

-(id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(int)index
{
    return [[records objectAtIndex:index] objectForKey:[tableColumn identifier]];
}

-(void)tableView:(NSTableView*)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn*)tableColumn row:(int)index
{
    if(nil == value)
        value = @"";
    if([[tableColumn identifier] isEqual:@"combo"])
        [[records objectAtIndex:index] setObject:value forKey:@"combo"];
}

/* delegate for the NSTableView
 since there's only one combo box for all the lines, we need to populate it with the proper
 values for the line as set its selection, etc.
 this is optional, the alternative is to set a list of values in interface builder  */

-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)index
{
    if([[tableColumn identifier] isEqual:@"combo"] && [cell isKindOfClass:[NSComboBoxCell class]])
    {
        NSDictionary *dic = [records objectAtIndex:index];
        [cell setRepresentedObject:[dic objectForKey:@"combov"]];
        [cell reloadData];
        [cell selectItemAtIndex:[self comboBoxCell:cell indexOfItemWithStringValue:[dic objectForKey:@"combo"]]];
        [cell setObjectValue:[dic objectForKey:@"combo"]];
    }
}

@end