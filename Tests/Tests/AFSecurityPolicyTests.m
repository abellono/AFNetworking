// PURSecurityPolicyTests.m
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

#import "PURTestCase.h"
#import "PURSecurityPolicy.h"

@interface PURSecurityPolicyTests : PURTestCase

@end

static SecTrustRef PURUTTrustChainForCertsInDirectory(NSString *directoryPath) {
    NSArray *certFileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray *certs  = [NSMutableArray arrayWithCapacity:[certFileNames count]];
    for (NSString *path in certFileNames) {
        NSData *certData = [NSData dataWithContentsOfFile:[directoryPath stringByAppendingPathComponent:path]];
        SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
        [certs addObject:(__bridge_transfer id)(cert)];
    }

    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust = NULL;
    SecTrustCreateWithCertificates((__bridge CFTypeRef)(certs), policy, &trust);
    CFRelease(policy);

    return trust;
}

static SecTrustRef PURUTHTTPBinOrgServerTrust() {
    NSString *bundlePath = [[NSBundle bundleForClass:[PURSecurityPolicyTests class]] resourcePath];
    NSString *serverCertDirectoryPath = [bundlePath stringByAppendingPathComponent:@"HTTPBinOrgServerTrustChain"];

    return PURUTTrustChainForCertsInDirectory(serverCertDirectoryPath);
}

static SecTrustRef PURUTADNNetServerTrust() {
    NSString *bundlePath = [[NSBundle bundleForClass:[PURSecurityPolicyTests class]] resourcePath];
    NSString *serverCertDirectoryPath = [bundlePath stringByAppendingPathComponent:@"ADNNetServerTrustChain"];

    return PURUTTrustChainForCertsInDirectory(serverCertDirectoryPath);
}

static SecCertificateRef PURUTHTTPBinOrgCertificate() {
    NSString *certPath = [[NSBundle bundleForClass:[PURSecurityPolicyTests class]] pathForResource:@"httpbinorg_04082019" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef PURUTLetsEncryptAuthorityCertificate() {
    NSString *certPath = [[NSBundle bundleForClass:NSClassFromString(@"PURSecurityPolicyTests")] pathForResource:@"Let's Encrypt Authority X3" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];
    
    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef PURUTDSTRootCertificate() {
    NSString *certPath = [[NSBundle bundleForClass:NSClassFromString(@"PURSecurityPolicyTests")] pathForResource:@"DST Root CA X3" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];
    
    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef PURUTSelfSignedCertificateWithoutDomain() {
    NSString *certPath = [[NSBundle bundleForClass:[PURSecurityPolicyTests class]] pathForResource:@"NoDomains" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef PURUTSelfSignedCertificateWithCommonNameDomain() {
    NSString *certPath = [[NSBundle bundleForClass:[PURSecurityPolicyTests class]] pathForResource:@"foobar.com" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecCertificateRef PURUTSelfSignedCertificateWithDNSNameDomain() {
    NSString *certPath = [[NSBundle bundleForClass:[PURSecurityPolicyTests class]] pathForResource:@"AltName" ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];

    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

static SecTrustRef PURUTTrustWithCertificate(SecCertificateRef certificate) {
    NSArray *certs  = @[(__bridge id)(certificate)];

    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust = NULL;
    SecTrustCreateWithCertificates((__bridge CFTypeRef)(certs), policy, &trust);
    CFRelease(policy);

    return trust;
}

@implementation PURSecurityPolicyTests

#pragma mark - Default Policy Tests
#pragma mark Default Values Test

- (void)testDefaultPolicyPinningModeIsSetToNone {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    XCTAssertTrue(policy.SSLPinningMode == PURSSLPinningModeNone, @"Pinning Mode should be set to by default");
}

- (void)testDefaultPolicyHasInvalidCertificatesAreDisabledByDefault {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    XCTAssertFalse(policy.allowInvalidCertificates, @"Invalid Certificates Should Be Disabled by Default");
}

- (void)testDefaultPolicyHasDomainNamesAreValidatedByDefault {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    XCTAssertTrue(policy.validatesDomainName, @"Domain names should be validated by default");
}

- (void)testDefaultPolicyHasNoPinnedCertificates {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    XCTAssertTrue(policy.pinnedCertificates.count == 0, @"The default policy should not have any pinned certificates");
}

#pragma mark Positive Server Trust Evaluation Tests

- (void)testDefaultPolicyDoesAllowHTTPBinOrgCertificate {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    SecTrustRef trust = PURUTHTTPBinOrgServerTrust();
    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:nil], @"Valid Certificate should be allowed by default.");
}

- (void)testDefaultPolicyDoesAllowHTTPBinOrgCertificateForValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    SecTrustRef trust = PURUTHTTPBinOrgServerTrust();
    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"httpbin.org"], @"Valid Certificate should be allowed by default.");
}

#pragma mark Negative Server Trust Evaluation Tests

- (void)testDefaultPolicyDoesNotAllowInvalidCertificate {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    SecCertificateRef certificate = PURUTSelfSignedCertificateWithoutDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);
    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:nil], @"Invalid Certificates should not be allowed");
}

- (void)testDefaultPolicyDoesNotAllowCertificateWithInvalidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    SecTrustRef trust = PURUTHTTPBinOrgServerTrust();
    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"apple.com"], @"Certificate should not be allowed because the domain names do not match.");
}

#pragma mark - Public Key Pinning Tests
#pragma mark Default Values Tests

- (void)testPolicyWithPublicKeyPinningModeHasPinnedCertificates {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    XCTAssertTrue(policy.pinnedCertificates > 0, @"Policy should contain default pinned certificates");
}

- (void)testPolicyWithPublicKeyPinningModeHasHTTPBinOrgPinnedCertificate {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey withPinnedCertificates:[PURSecurityPolicy certificatesInBundle:bundle]];

    SecCertificateRef cert = PURUTHTTPBinOrgCertificate();
    NSData *certData = (__bridge NSData *)(SecCertificateCopyData(cert));
    CFRelease(cert);
    NSSet *set = [policy.pinnedCertificates objectsPassingTest:^BOOL(NSData *data, BOOL *stop) {
        return [data isEqualToData:certData];
    }];

    XCTAssertEqual(set.count, 1U, @"HTTPBin.org certificate not found in the default certificates");
}

#pragma mark Positive Server Trust Evaluation Tests
- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeafCertificatePinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];

    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgIntermediateCertificatePinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    
    SecCertificateRef certificate = PURUTLetsEncryptAuthorityCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgRootCertificatePinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    
    SecCertificateRef certificate = PURUTDSTRootCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithEntireCertificateChainPinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    
    SecCertificateRef httpBinCertificate = PURUTHTTPBinOrgCertificate();
    SecCertificateRef intermediateCertificate = PURUTLetsEncryptAuthorityCertificate();
    SecCertificateRef rootCertificate = PURUTDSTRootCertificate();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                   (__bridge_transfer NSData *)SecCertificateCopyData(intermediateCertificate),
                                   (__bridge_transfer NSData *)SecCertificateCopyData(rootCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");
    
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBirnOrgServerTrustWithHTTPbinOrgPinnedCertificateAndAdditionalPinnedCertificates {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    
    SecCertificateRef httpBinCertificate = PURUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = PURUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                   (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");
}

- (void)testPolicyWithPublicKeyPinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeafCertificatePinnedAndValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    
    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:@"httpbin.org"], @"Policy should allow server trust");
}

#pragma mark Negative Server Trust Evaluation Tests

- (void)testPolicyWithPublicKeyPinningAndNoPinnedCertificatesDoesNotAllowHTTPBinOrgServerTrust {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    policy.pinnedCertificates = [NSSet set];
    XCTAssertFalse([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should not allow server trust because the policy is set to public key pinning and it does not contain any pinned certificates.");
}

- (void)testPolicyWithPublicKeyPinningDoesNotAllowADNServerTrustWithHTTPBinOrgPinnedCertificate {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];

    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:PURUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust for pinned HTTPBin.org certificate");
}

- (void)testPolicyWithPublicKeyPinningDoesNotAllowHTTPBinOrgServerTrustWithHTTPBinOrgLeafCertificatePinnedAndInvalidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];

    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:@"invaliddomainname.com"], @"Policy should not allow server trust");
}

- (void)testPolicyWithPublicKeyPinningDoesNotAllowADNServerTrustWithMultipleInvalidPinnedCertificates {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];

    SecCertificateRef httpBinCertificate = PURUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = PURUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertFalse([policy evaluateServerTrust:PURUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust because there are no matching pinned certificates");
}

#pragma mark - Certificate Pinning Tests
#pragma mark Default Values Tests

- (void)testPolicyWithCertificatePinningModeHasPinnedCertificates {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    XCTAssertTrue(policy.pinnedCertificates > 0, @"Policy should contain default pinned certificates");
}

- (void)testPolicyWithCertificatePinningModeHasHTTPBinOrgPinnedCertificate {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate withPinnedCertificates:[PURSecurityPolicy certificatesInBundle:bundle]];

    SecCertificateRef cert = PURUTHTTPBinOrgCertificate();
    NSData *certData = (__bridge NSData *)(SecCertificateCopyData(cert));
    CFRelease(cert);
    NSSet *set = [policy.pinnedCertificates objectsPassingTest:^BOOL(NSData *data, BOOL *stop) {
        return [data isEqualToData:certData];
    }];

    XCTAssertEqual(set.count, 1U, @"HTTPBin.org certificate not found in the default certificates");
}

#pragma mark Positive Server Trust Evaluation Tests
- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeafCertificatePinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];

    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgIntermediateCertificatePinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    
    SecCertificateRef certificate = PURUTLetsEncryptAuthorityCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgRootCertificatePinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    
    SecCertificateRef certificate = PURUTDSTRootCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow server trust");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithEntireCertificateChainPinned {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    
    SecCertificateRef httpBinCertificate = PURUTHTTPBinOrgCertificate();
    SecCertificateRef intermediateCertificate = PURUTLetsEncryptAuthorityCertificate();
    SecCertificateRef rootCertificate = PURUTDSTRootCertificate();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                   (__bridge_transfer NSData *)SecCertificateCopyData(intermediateCertificate),
                                   (__bridge_transfer NSData *)SecCertificateCopyData(rootCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");
    
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBirnOrgServerTrustWithHTTPbinOrgPinnedCertificateAndAdditionalPinnedCertificates {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    
    SecCertificateRef httpBinCertificate = PURUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = PURUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                   (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should allow HTTPBinOrg server trust because at least one of the pinned certificates is valid");
}

- (void)testPolicyWithCertificatePinningAllowsHTTPBinOrgServerTrustWithHTTPBinOrgLeafCertificatePinnedAndValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    
    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:@"httpbin.org"], @"Policy should allow server trust");
}

#pragma mark Negative Server Trust Evaluation Tests

- (void)testPolicyWithCertificatePinningAndNoPinnedCertificatesDoesNotAllowHTTPBinOrgServerTrust {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    policy.pinnedCertificates = [NSSet set];
    XCTAssertFalse([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:nil], @"Policy should not allow server trust because the policy does not contain any pinned certificates.");
}

- (void)testPolicyWithCertificatePinningDoesNotAllowADNServerTrustWithHTTPBinOrgPinnedCertificate {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];

    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:PURUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust for pinned HTTPBin.org certificate");
}

- (void)testPolicyWithCertificatePinningDoesNotAllowHTTPBinOrgServerTrustWithHTTPBinOrgLeafCertificatePinnedAndInvalidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];

    SecCertificateRef certificate = PURUTHTTPBinOrgCertificate();
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(certificate)];
    XCTAssertFalse([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:@"invaliddomainname.com"], @"Policy should not allow server trust");
}

- (void)testPolicyWithCertificatePinningDoesNotAllowADNServerTrustWithMultipleInvalidPinnedCertificates {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];

    SecCertificateRef httpBinCertificate = PURUTHTTPBinOrgCertificate();
    SecCertificateRef selfSignedCertificate = PURUTSelfSignedCertificateWithCommonNameDomain();
    [policy setPinnedCertificates:[NSSet setWithObjects:(__bridge_transfer NSData *)SecCertificateCopyData(httpBinCertificate),
                                                        (__bridge_transfer NSData *)SecCertificateCopyData(selfSignedCertificate), nil]];
    XCTAssertFalse([policy evaluateServerTrust:PURUTADNNetServerTrust() forDomain:nil], @"Policy should not allow ADN server trust because there are no matching pinned certificates");
}

#pragma mark - Domain Name Validation Tests
#pragma mark Positive Evaluation Tests

- (void)testThatPolicyWithoutDomainNameValidationAllowsServerTrustWithInvalidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    [policy setValidatesDomainName:NO];
    XCTAssertTrue([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:@"invalid.org"], @"Policy should allow server trust because domain name validation is disabled");
}

- (void)testThatPolicyWithDomainNameValidationAndSelfSignedCommonNameCertificateAllowsServerTrust {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];

    SecCertificateRef certificate = PURUTSelfSignedCertificateWithCommonNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];
    [policy setAllowInvalidCertificates:YES];

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust");
}

- (void)testThatPolicyWithDomainNameValidationAndSelfSignedDNSCertificateAllowsServerTrust {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];

    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];
    [policy setAllowInvalidCertificates:YES];

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust");
}

#pragma mark Negative Evaluation Tests

- (void)testThatPolicyWithDomainNameValidationDoesNotAllowServerTrustWithInvalidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    XCTAssertFalse([policy evaluateServerTrust:PURUTHTTPBinOrgServerTrust() forDomain:@"invalid.org"], @"Policy should not allow allow server trust");
}

- (void)testThatPolicyWithDomainNameValidationAndSelfSignedNoDomainCertificateDoesNotAllowServerTrust {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];

    SecCertificateRef certificate = PURUTSelfSignedCertificateWithoutDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];
    [policy setAllowInvalidCertificates:YES];

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust");
}

#pragma mark - Self Signed Certificate Tests
#pragma mark Positive Test Cases

- (void)testThatPolicyWithInvalidCertificatesAllowedAllowsSelfSignedServerTrust {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];
    [policy setAllowInvalidCertificates:YES];

    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:nil], @"Policy should allow server trust because invalid certificates are allowed");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndValidPinnedCertificatesDoesAllowSelfSignedServerTrustForValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    [policy setAllowInvalidCertificates:YES];
    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust because invalid certificates are allowed");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndNoSSLPinningAndDomainNameValidationDisabledDoesAllowSelfSignedServerTrustForValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeNone];
    [policy setAllowInvalidCertificates:YES];
    [policy setValidatesDomainName:NO];

    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);

    XCTAssertTrue([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should allow server trust because invalid certificates are allowed");
}

#pragma mark Negative Test Cases

- (void)testThatPolicyWithInvalidCertificatesDisabledDoesNotAllowSelfSignedServerTrust {
    PURSecurityPolicy *policy = [PURSecurityPolicy defaultPolicy];

    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:nil], @"Policy should not allow server trust because invalid certificates are not allowed");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndNoPinnedCertificatesAndPublicKeyPinningModeDoesNotAllowSelfSignedServerTrustForValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModePublicKey];
    [policy setAllowInvalidCertificates:YES];
    [policy setPinnedCertificates:[NSSet set]];
    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust because invalid certificates are allowed but there are no pinned certificates");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndValidPinnedCertificatesAndNoPinningModeDoesNotAllowSelfSignedServerTrustForValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeNone];
    [policy setAllowInvalidCertificates:YES];
    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);
    [policy setPinnedCertificates:[NSSet setWithObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)]];

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust because invalid certificates are allowed but there are no pinned certificates");
}

- (void)testThatPolicyWithInvalidCertificatesAllowedAndNoValidPinnedCertificatesAndNoPinningModeAndDomainValidationDoesNotAllowSelfSignedServerTrustForValidDomainName {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeNone];
    [policy setAllowInvalidCertificates:YES];
    [policy setPinnedCertificates:[NSSet set]];

    SecCertificateRef certificate = PURUTSelfSignedCertificateWithDNSNameDomain();
    SecTrustRef trust = PURUTTrustWithCertificate(certificate);

    XCTAssertFalse([policy evaluateServerTrust:trust forDomain:@"foobar.com"], @"Policy should not allow server trust because invalid certificates are allowed but there are no pinned certificates");
}

#pragma mark - NSCopying
- (void)testThatPolicyCanBeCopied {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = NO;
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(PURUTHTTPBinOrgCertificate())];

    PURSecurityPolicy *copiedPolicy = [policy copy];
    XCTAssertNotEqual(copiedPolicy, policy);
    XCTAssertEqual(copiedPolicy.allowInvalidCertificates, policy.allowInvalidCertificates);
    XCTAssertEqual(copiedPolicy.validatesDomainName, policy.validatesDomainName);
    XCTAssertEqual(copiedPolicy.SSLPinningMode, policy.SSLPinningMode);
    XCTAssertTrue([copiedPolicy.pinnedCertificates isEqualToSet:policy.pinnedCertificates]);
}

- (void)testThatPolicyCanBeEncodedAndDecoded {
    PURSecurityPolicy *policy = [PURSecurityPolicy policyWithPinningMode:PURSSLPinningModeCertificate];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = NO;
    policy.pinnedCertificates = [NSSet setWithObject:(__bridge_transfer id)SecCertificateCopyData(PURUTHTTPBinOrgCertificate())];

    NSMutableData *archiveData = [NSMutableData new];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
    [archiver encodeObject:policy forKey:@"policy"];
    [archiver finishEncoding];

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archiveData];
    PURSecurityPolicy *unarchivedPolicy = [unarchiver decodeObjectOfClass:[PURSecurityPolicy class] forKey:@"policy"];

    XCTAssertNotEqual(unarchivedPolicy, policy);
    XCTAssertEqual(unarchivedPolicy.allowInvalidCertificates, policy.allowInvalidCertificates);
    XCTAssertEqual(unarchivedPolicy.validatesDomainName, policy.validatesDomainName);
    XCTAssertEqual(unarchivedPolicy.SSLPinningMode, policy.SSLPinningMode);
    XCTAssertTrue([unarchivedPolicy.pinnedCertificates isEqualToSet:policy.pinnedCertificates]);
}

@end
