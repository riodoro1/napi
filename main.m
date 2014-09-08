//
//  main.m
//  napi
//
//  Created by Rafał Białek on 08/09/14.
//  Copyright (c) 2014 Rafał Białek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+URLArgumentsWithDictionary.h"
#import "NSData+MD5Sum.h"
#import "XmlReader.h"

int main(int argc, const char * argv[])
{
    if (argc!=3) return -1;
    //First parameter is filename of movie file
    //Second parameter is language of subtitles to be downloaded in abbreviated form eg. "PL" or "ENG"
    @autoreleasepool
    {
        
        NSLog(@"%s",argv[0]);
        
        NSString *filename = [NSString stringWithUTF8String:argv[1]];
        NSString *lang = [NSString stringWithUTF8String:argv[2]];
        NSLog(@"Will download subtitles for:\n%@",filename);
        NSLog(@"With language: %@",lang);
        
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:filename];
        if(!file)
        {
            NSLog(@"File does not exist!");
            return -1;
        }
        NSData *fileData=[file readDataOfLength:10485760];
        
        NSString *URLBody = @"http://napiprojekt.pl/api/api-napiprojekt3.php";
        NSString *URLArgs = [[[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"mode",@"NapiProjektPython",@"client",@"0.1",@"client_ver",[fileData MD5Sum],@"downloaded_subtitles_id",@"1",@"downloaded_subtitles_txt",lang,@"downloaded_subtitles_lang", nil] URLArguments];
        
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLBody]];
        [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [postRequest setHTTPMethod:@"POST"];
        [postRequest setHTTPBody:[NSData dataWithBytes:[URLArgs UTF8String] length:strlen([URLArgs UTF8String])]];
        
        NSError *error=nil;
        
        NSData *response = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:nil error:&error];
        if(error)
        {
            NSLog(@"Error while downloading data: %@",[error description]);
            return -1;
        }
        
        //response ready to be processed!
        
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:response error:&error];
        if(error)
        {
            NSLog(@"Error while parsing data: %@",[error description]);
            return -1;
        }
        
        
        if(![[[[xmlDictionary valueForKey:@"result"] valueForKey:@"status"] valueForKey:@"text"] isEqual:@"success"])
        {
            NSLog(@"No subtitles found!");
            return 0;
        }
        
        NSLog(@"%@ in %@",[[[xmlDictionary valueForKey:@"result"] valueForKey:@"status"] valueForKey:@"text"],[[[xmlDictionary valueForKey:@"result"] valueForKey:@"response_time"] valueForKey:@"text"]);
        
        NSString *subtitlesRaw = [[[[xmlDictionary valueForKey:@"result"] valueForKey:@"subtitles"] valueForKey:@"content"] valueForKey:@"text"];
        
        NSData *subtitlesDecoded = [[NSData alloc] initWithBase64EncodedString:subtitlesRaw options:0];
        
        [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@%@",[filename stringByDeletingPathExtension], @".txt"] contents:subtitlesDecoded attributes:nil];
    }
    return 0;
}

