//
//  Insect.h
//  Cicada Hunt
//
//  Created by acr on 28/04/2013.
//  Copyright (c) 2013 New Forest Cicada Project. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
                INSECT_TYPE_CICADA,
                INSECT_TYPE_FIELD_GRASSHOPPER,
                INSECT_TYPE_DARK_BUSH_CRICKET,
                INSECT_TYPE_ROESELS_BUSH_CRICKET,
                INSECT_TYPE_WOOD_CRICKET,
                INSECT_TYPE_NONE_OF_THESE = 99

             } insect_t;
    
@interface Insect : NSObject

@property (nonatomic) float value;

-(id)initWithInsect:(insect_t)insect andValue:(float)v andFound:(BOOL)f;

@end
