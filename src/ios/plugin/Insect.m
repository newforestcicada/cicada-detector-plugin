//
//  Insect.m
//  Cicada Hunt
//
//  Created by acr on 28/04/2013.
//  Copyright (c) 2013 New Forest Cicada Project. All rights reserved.
//

#import "Insect.h"

@interface Insect () {
    
    insect_t _insectType;
    BOOL _found;
    
}
    
@end

@implementation Insect

//@synthesize value;

-(id)initWithInsect:(insect_t)insect andValue:(float)v andFound:(BOOL)f;
{
    if ( self = [super init] ) {
        _insectType = insect;
        _value = v;
        _found = f;
    }
    return self;    
}

-(NSString *)description
{

    NSString *insectName;
    
    switch (_insectType) {
        case INSECT_TYPE_CICADA:
            insectName = @"New Forest Cicada";
            break;
        case INSECT_TYPE_FIELD_GRASSHOPPER:
            insectName = @"Field Grasshopper";
            break;
        case INSECT_TYPE_DARK_BUSH_CRICKET:
            insectName = @"Dark Bush-Cricket";
            break;
        case INSECT_TYPE_ROESELS_BUSH_CRICKET:
            insectName = @"Roesel's Bush-Cricket";
            break;
        case INSECT_TYPE_WOOD_CRICKET:
            insectName = @"Wood Cricket";
            break;
        case INSECT_TYPE_NONE_OF_THESE:
            insectName = @"None Of These";
        break;
    }

    NSString *foundString;
    
    if (_found) {
        foundString = @"true";
    } else {
        foundString = @"false";
    }
    
    NSString *returnString = [NSString stringWithFormat:@"{ \"insect\" : %d, \"name\" : \"%@\", \"value\" : %.2f , \"found\" : %@ }",_insectType,insectName,_value,foundString];
    
    return returnString;
    
}

- (NSComparisonResult)compare:(Insect*)otherInsect {
    if (_value > [otherInsect value]) {
        return NSOrderedAscending;
    } else if (_value < [otherInsect value]) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

@end
