// PURNetworking.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

//! Project version number for PURNetworking.
FOUNDATION_EXPORT double PURNetworkingVersionNumber;

//! Project version string for PURNetworking.
FOUNDATION_EXPORT const unsigned char PURNetworkingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PURNetworking/PublicHeader.h>

#import <Availability.h>
#import <TargetConditionals.h>

#ifndef _PURNETWORKING_
#define _PURNETWORKING_

#import <PURNetworking/PURURLRequestSerialization.h>
#import <PURNetworking/PURURLResponseSerialization.h>
#import <PURNetworking/PURSecurityPolicy.h>
#import <PURNetworking/PURCompatibilityMacros.h>

#if !TARGET_OS_WATCH
#import <PURNetworking/PURNetworkReachabilityManager.h>
#endif

#import <PURNetworking/PURURLSessionManager.h>
#import <PURNetworking/PURHTTPSessionManager.h>

#if TARGET_OS_IOS || TARGET_OS_TV
#import <PURNetworking/PURAutoPurgingImageCache.h>
#import <PURNetworking/PURImageDownloader.h>
#import <PURNetworking/UIActivityIndicatorView+PURNetworking.h>
#import <PURNetworking/UIButton+PURNetworking.h>
#import <PURNetworking/UIImage+PURNetworking.h>
#import <PURNetworking/UIImageView+PURNetworking.h>
#import <PURNetworking/UIProgressView+PURNetworking.h>
#endif

#if TARGET_OS_IOS
#import <PURNetworking/PURNetworkActivityIndicatorManager.h>
#import <PURNetworking/UIRefreshControl+PURNetworking.h>
#import <PURNetworking/UIWebView+PURNetworking.h>
#endif


#endif /* _PURNETWORKING_ */
