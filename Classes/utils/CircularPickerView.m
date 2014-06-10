//
//  CircularPickerView.m
//
//  This class is a drop in replacement for the iPhone UI component UIPickerView.
//  This component emulates circular picker wheels. From a user interface point of
//  view it is best that the number of rows in a component be in the range 8 - 20.
//  This range is just a recommendation. But components with less than 6 rows is a bad
//  idea since the picker will show 5 rows at a time using the default sizes.
//
//  Created by Rick Maddy on 12/16/08.
//  Submitted to the public domain.
//

#import "CircularPickerView.h"

// This is our base row
static int kBase = 10000;

@implementation CircularPickerView

// This is overloaded because out UIPickerViewDelegate responds to all of the UIPickerViewDelegate methods but the
// client's delegate may not. This code tricks the base UIPickerView into thinking its delegate has the same
// methods as the client's.
- (BOOL) respondsToSelector:(SEL)aSelector
{
    if (aSelector == @selector(pickerView:rowHeightForComponent:))
        return [myDelegate respondsToSelector:aSelector];
    else if (aSelector == @selector(pickerView:viewForRow:forComponent:reusingView:))
        return [myDelegate respondsToSelector:aSelector];
    else if (aSelector == @selector(pickerView:widthForComponent:))
        return [myDelegate respondsToSelector:aSelector];
    else if (aSelector == @selector(pickerView:titleForRow:forComponent:))
        return [myDelegate respondsToSelector:aSelector];
	
	return [super respondsToSelector:aSelector];
}

// Convert a client's row number into the fake one we tell to the picker
- (NSInteger) convertLogicalRowToPhysicalRow:(NSInteger)logical component:(NSInteger)component
{
    return (logical % [self numberOfRowsInComponent:component]) + kBase;
}

// Convert the fake row we tell to the picker into a row the client understands
- (NSInteger) convertPhysicalRowToLogicalRow:(NSInteger)physical component:(NSInteger)component
{
    NSInteger logical = 0;
    int cnt = [self numberOfRowsInComponent:component];
    if (physical > kBase)
	{
        int diff = physical - kBase;
        int mod = diff % cnt;
        logical = mod;
    }
	else
	{
        int diff = kBase - physical;
        int mod = diff % cnt;
		logical = (mod) ? cnt - mod : 0;
    }
    
    return logical;
}

#pragma mark UIPickerViewDataSource methods

// Simply pass this request on to the client's data source
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [myDataSource numberOfComponentsInPickerView:pickerView];
}

// We tell the pick view that there are many thousands of rows to simulate a never ending picker wheel
// but we internally keep track of how many rows the client says there are.
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int cnt = [myDataSource pickerView:pickerView numberOfRowsInComponent:component];
    rowCounts[component] = cnt;
    
    return kBase * 2;
}

#pragma mark UIPickerViewDelegate methods

// The picker is telling us that a row has been selected. This happens when the wheel stops moving.
// We need to convert the fake row the picker has into a row number the client understands and tell the
// client that that row was selected.
// Then we reset the picker's selected row back toward the center. This way the wheel is always near the center
// of it rather large range.
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Convert the picker's fake row into a client row
    NSInteger logical = [self convertPhysicalRowToLogicalRow:row component:component];
    // Reconvert the client row back into a fake row. This forces the row to stay near the center
    NSInteger physical = [self convertLogicalRowToPhysicalRow:logical component:component];
    // Reset the picker's selected row back toward the middle if needed.
    if (physical != row)
        [pickerView selectRow:physical inComponent:component animated:NO];

    // Now tell the client about the row selection
    if ([myDelegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)])
        [myDelegate pickerView:pickerView didSelectRow:logical inComponent:component];
}

// This is an optional delegate method. This will only get called if the client delegate implements this method.
// Just pass the request on to the client's delegate.
- (CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return [myDelegate pickerView:pickerView rowHeightForComponent:component];
}

// This is an optional delegate method. This will only get called if the client delegate implements this method.
// Convert the row before passing the request on to the client's delegate.
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger logical = [self convertPhysicalRowToLogicalRow:row component:component];
    return [myDelegate pickerView:pickerView titleForRow:logical forComponent:component];
}

// This is an optional delegate method. This will only get called if the client delegate implements this method.
// Convert the row before passing the request on to the client's delegate.
- (UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSInteger logical = [self convertPhysicalRowToLogicalRow:row component:component];
    return [myDelegate pickerView:pickerView viewForRow:logical forComponent:component reusingView:view];
}

// This is an optional delegate method. This will only get called if the client delegate implements this method.
// Just pass the request on to the client's delegate.
- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [myDelegate pickerView:pickerView widthForComponent:component];
}

#pragma mark UIPickerView methods

- (id<UIPickerViewDataSource>) dataSource
{
    return myDataSource;
}

// Intercept changes to the data source. We must always be the picker's data source.
- (void) setDataSource:(id<UIPickerViewDataSource>)dataSource
{
    myDataSource = dataSource;
    [super setDataSource:self];
}

- (id<UIPickerViewDelegate>) delegate
{
    return myDelegate;
}

// Intercept changes to the delegate. We must always be the picker's delegate.
- (void) setDelegate:(id<UIPickerViewDelegate>)delegate
{
    myDelegate = delegate;
    [super setDelegate:self];
}

// Reset our internal list of row counts
- (void) reloadAllComponents
{
    for (int i = 0; i < kMaxComponents; i++)
        rowCounts[i] = 0;

    [super reloadAllComponents];
}

// Reset our internal row count
- (void) reloadComponent:(NSInteger)component
{
    rowCounts[component] = 0;
    [super reloadComponent:component];
}

// Since we tell the pick all components have thousands of rows per component, we need to track how many each
// one really has.
- (NSInteger) numberOfRowsInComponent:(NSInteger)component
{
    if (rowCounts[component] == 0)
        rowCounts[component] = [myDataSource pickerView:self numberOfRowsInComponent:component];
    
    // Assume this is only called by client and not internally
    return rowCounts[component];
}

// Convert picker's fake row into a client friendly row
- (NSInteger) selectedRowInComponent:(NSInteger)component
{
    NSInteger physical = [super selectedRowInComponent:component];    
    return [self convertPhysicalRowToLogicalRow:physical component:component];
}

// Convert the client's row into the fake row used by the picker
- (void) selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    NSInteger physical = [self convertLogicalRowToPhysicalRow:row component:component];
    [super selectRow:physical inComponent:component animated:animated];
}

// Convert the client's row into the fake row used by the picker
- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger physical = [self convertLogicalRowToPhysicalRow:row component:component];    
    return [super viewForRow:physical forComponent:component];
}

@end
