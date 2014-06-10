//
//  CircularPickerView.h
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

#import <UIKit/UIKit.h>

// Assume a maximum number of components. If you client code needs more than this, change the value
#define kMaxComponents 10

@interface CircularPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>
{
    @private
    id<UIPickerViewDataSource> myDataSource;
    id<UIPickerViewDelegate> myDelegate;
    NSInteger rowCounts[kMaxComponents];
}

@end
