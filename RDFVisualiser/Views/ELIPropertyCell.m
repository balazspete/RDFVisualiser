//
//  ELIPropertyCell.m
//  RDFVisualiser
//
//  Created by Balázs Pete on 15/04/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIPropertyCell.h"

@implementation ELIPropertyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
