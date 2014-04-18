//
//  ELIPropertyCell.h
//  RDFVisualiser
//
//  Created by Balázs Pete on 15/04/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELIPropertyCell : UITableViewCell

@property bool isLink;
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end
