//
//  STMPicturesViewerDelegate.h
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 14/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#ifndef STMPicturesViewerDelegate_h
#define STMPicturesViewerDelegate_h

@protocol STMPicturesViewerDelegate <NSObject>

@required

- (void)photoWasDeleted:(STMCorePhoto *)photo;

@end


#endif /* STMPicturesViewerDelegate_h */
