//
//  STMConstants.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#ifndef iSistemium_STMConstants_h
#define iSistemium_STMConstants_h

#define ISISTEMIUM_PREFIX @"STM"

#define ACTIVE_BLUE_COLOR [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]
#define GREY_LINE_COLOR [UIColor colorWithRed:0.785 green:0.78 blue:0.8 alpha:1]
#define STM_LIGHT_BLUE_COLOR [UIColor colorWithRed:0.56 green:0.77 blue:1 alpha:1]
#define STM_SUPERLIGHT_BLUE_COLOR [UIColor colorWithRed:0.92 green:0.96 blue:1 alpha:1]
#define STM_YELLOW_COLOR [UIColor colorWithRed:1 green:0.98 blue:0 alpha:1]
#define STM_LIGHT_LIGHT_GREY_COLOR [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]

#define STM_SECTION_HEADER_COLOR [UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];

#define MAX_PICTURE_SIZE 3500.0

#define TICK NSDate *startTime = [NSDate date]
#define TOCK NSLog(@"ElapsedTime: %f", -[startTime timeIntervalSinceNow])

#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define NSLogMethodName NSLog(@"%@", NSStringFromSelector(_cmd))

#define BUILD_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]
#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

#define MAGIC_NUMBER_FOR_CELL_WIDTH 16

#define TOOLBAR_HEIGHT 44

#define GEOTRACKER_CONTROL_SHIPMENT_ROUTE @"ShipmentRoute"


// Notification's names

#define SYNCER_GET_BUNCH_OF_OBJECTS @"syncerGetBunchOfObjects"


#endif
