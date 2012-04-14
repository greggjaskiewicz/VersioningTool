//
//  main.m
//  VersioningTool
//
//  Created by Greg Jaskiewicz on 14/04/2012.
//  Copyright (c) 2012 K4Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCFBundleVersionKey @"CFBundleVersion"

/* our workhorse class */
@interface foo

+ (void) bumpVersion:(NSString*)ForInfo;
+ (NSArray*) findInfoFilesRecursive:(NSString*)forDirectory;

@end

@implementation foo

+ (NSArray*) findInfoFilesRecursive:(NSString*)forDirectory
{
  NSMutableArray *list = [[NSMutableArray alloc] init];
  NSFileManager* fileManager = [NSFileManager defaultManager];
  
  /* if directory is nil, use current working dir */
  if (!forDirectory)
  {
    forDirectory = [fileManager currentDirectoryPath];
  }
  
  NSDirectoryEnumerator *directory = [fileManager enumeratorAtPath:forDirectory];

  for(NSString* file in directory)
  {
    if ([[file pathExtension] isEqualToString:@"plist"])
    {
      NSString* newFile = [forDirectory stringByAppendingString:@"/"];
      newFile = [newFile stringByAppendingString:file];
      [list addObject:newFile];
    }
  }
  
  return list;
}

+ (void) bumpVersion:(NSString*)ForFilename;
{
  /* we need number formater to convert string to int */
  NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

  /* get the dictionary from the file */
  NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:ForFilename];
  
  /* only do the following if version isn't 0, and dictionary isn't nil */
  if (dictionary)
  {
    NSMutableDictionary *newDictionary = [dictionary mutableCopyWithZone:nil];
    id value = [newDictionary valueForKey:kCFBundleVersionKey];
        
    int version = [[numberFormatter numberFromString:[NSString stringWithFormat:@"%@", value]] intValue];

    if (version)
    {
      ++version;
      
      fprintf(stdout, "file: \"%s\" , new version:%d\n", 
              [ForFilename cStringUsingEncoding:NSASCIIStringEncoding], 
              version);
      
      [newDictionary setValue:[NSString stringWithFormat:@"%d", version] forKey:kCFBundleVersionKey];    
      [newDictionary writeToFile:ForFilename atomically:YES];    
    }
    else 
    {
      fprintf(stderr, "file \"%s\": the CFBundleVersion key does not exists or is not a positive number\n",
              [ForFilename cStringUsingEncoding:NSASCIIStringEncoding] );
    }
  }
  else 
  {
    fprintf(stderr, "the file \"%s\" is not in plist format\n",
            [ForFilename cStringUsingEncoding:NSASCIIStringEncoding] );
  }
}

@end



int main (int argc, const char * argv[]) 
{
  @autoreleasepool 
  {
    if ((argc == 2 || argc == 3) && !strcmp(argv[1], "-r"))
    {
      NSArray* plists = nil;
      
      if (argc == 3)
      {
        fprintf(stdout, "looking for .plist files in the specified directory recursively\n");
        plists = [foo findInfoFilesRecursive:[NSString stringWithCString:argv[2] encoding:NSASCIIStringEncoding]];        
      }
      else 
      {
        fprintf(stdout, "looking for .plist files in the current directory recursively\n");
        plists = [foo findInfoFilesRecursive:nil];
      }
      for(NSString* file in plists)
      {
        [foo bumpVersion:file];
      }
      fprintf(stdout, "done\n");

    }
    else 
    {      
      if (argc > 1)
      {
        for(size_t i=1;i<argc;i++)
        {
          NSString *filename = [[NSString alloc] initWithFormat:@"%s", argv[1]];
          [foo bumpVersion:filename];
        }
        fprintf(stdout, "done\n");
      }
      else 
      {
        fprintf(stderr, "VersioningTool v1.0, by Greg Jaskiewicz (c) 2012 \n");
        fprintf(stderr, "Give us either a list of plist files, -r for recursive search, or gtfo\n");
      }
      
    }

  }
  
  return 0;
} 

