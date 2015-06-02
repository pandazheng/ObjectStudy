//
//  Video.m
//  JSON & XML
//
//  Created by apple on 13-10-10.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "Video.h"

@interface Video()

@end

@implementation Video

- (NSString *)lengthStr
{
    return [NSString stringWithFormat:@"%02ld:%02ld", self.length / 60, self.length % 60];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Video: %p, video id: %ld, name: %@"
            "length: %ld videoURL: %@ imageURL: %@ desc: %@"
            "teacher: %@ >", self, (long)self.videoId, self.name,
            (long)self.length, self.videoURL,
            self.imageURL, self.desc, self.teacher];
}

@end
