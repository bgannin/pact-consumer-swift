# Pact Consumer Swift

_This DSL is in very early stages of development, please bear with us as we give it some polish. Please raise any problems you have in the github issues._

This codebase provides a iOS DSL for creating pacts. If you are new to Pact, please read the Pact [README][pact-readme] first.

This DSL relies on the Ruby [pact-mock_service][pact-mock-service] gem to provide the mock service for the iOS tests.

### Getting Started

1. Install the [pact-mock_service][pact-mock-service]

  `sudo gem install pact-mock_service -v 0.2.3.pre.rc2`

1. Add the PactConsumerSwift library to your project
  1. Including PactConsumerSwift in a Git Repository Using Submodules

  ```sh
  mkdir Vendor # you can keep your submodules in their own directory
  git submodule add git@github.com:DiUS/pact-consumer-swift.git Vendor/pact-consumer-swift
  git submodule update --init --recursive

  2. Add `PactConsumerSwift.xcodeproj` to your test target

  Right-click on the group containing your application's tests and
  select `Add Files To YourApp...`.

  Next, select `PactConsumerSwift.xcodeproj`, from Vendor/pact-consumer-swift.

  Once you've added the PactConsumerSwift project, you should see it in Xcode's project
  navigator, grouped with your tests.

  ### 3. Link `PactConsumerSwift.framework`

   Link the `PactConsumerSwift.framework` during your test target's
  `Link Binary with Libraries` build phase. You should see the `PactConsumerSwift.framework`

  1. Setup your Test Target to run the pact server
    * Product -> Scheme -> Edit Scheme
      - Edit your test Scheme
    * Under Test, Pre-actions add a Run Script Action
      - "$SRCROOT"/Vendor/pact-consumer-swift/script/start_server.sh
      - make sure you provide the build settings from your project, otherwise SRCROOT will not be set
    * Under Test, Post-actions add a Run Script Action
      - "$SRCROOT"/Vendor/pact-consumer-swift/script/stop_server.sh
      - make sure you provide the build settings from your project, otherwise SRCROOT will not be set

1. Testing with Swift
  1. Write a Unit test similar to the following [Quick](https://github.com/Quick/Quick),

```swift
          import PactConsumerSwift

          ...

          it("it says Hello") {
              var hello = "not Goodbye"
              var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

              helloProvider.uponReceiving("a request for hello")
                           .withRequest(.GET, path: "/sayHello")
                           .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])

              //Run the tests
              helloProvider.run ( { (complete) -> Void in
                HelloClient(baseUrl: helloProvider.baseUrl).sayHello { (response) in
                  hello = response
                  complete()
                }
              }, result: { (verification) -> Void in
                expect(verification).to(equal(VerificationResult.PASSED))
              })

              expect(hello).toEventually(contain("Hello"))
            }
```
      See the specs in the iOS Swift Example directory for examples of asynchronous callbacks, how to expect error responses, and how to use query params.

1. Testing with Objective C
  1. Write a Unit test similar to the following [XCTest],
```objc
    @import PactConsumerSwift;
    ...
    - (void)testPact {
      typedef void (^CompleteBlock)();
      XCTestExpectation *exp = [self expectationWithDescription:@"Responds with hello"];

      MockService *mockService = [[MockService alloc] initWithProvider:@"Provider" consumer:@"consumer"];

      [[[mockService uponReceiving:@"a request for hello"]
                     withRequest:1 path:@"/sayHello" headers:nil body: nil]
                     willRespondWith:200 headers:@{@"Content-Type": @"application/json"} body: @"Hello" ];

      HelloClient *helloClient = [[HelloClient alloc] initWithBaseUrl:mockService.baseUrl];

      [mockService run:^(CompleteBlock complete) {
                         NSString *requestReply = [helloClient sayHello];
                         XCTAssertEqualObjects(requestReply, @"Hello");
                         complete();
                       }
                       result:^(PactVerificationResult result) {
                         XCTAssert(result == PactVerificationResultPassed);
                         [exp fulfill];
                       }];

      [self waitForExpectationsWithTimeout:5 handler:nil];
    }
```
### Caveat: Your Test Target Must Include At Least One Swift File

The Swift stdlib will not be linked into your test target, and thus
PactConsumerSwift will fail to execute properly, if you test target does not contain
*at least one* Swift file. If it does not, your tests will exit
prematurely with the following error:

```
*** Test session exited(82) without checking in. Executable cannot be
loaded for some other reason, such as a problem with a library it
depends on or a code signature/entitlements mismatch.
```

To fix the problem, add a blank file called `PactFix.swift` to your test target:

```swift
// PactFix.swift

import PactConsumerSwift
```

1. Verifying your client against the service you are integrating with

# Contributing

Please read [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact-readme]: https://github.com/realestate-com-au/pact
[pact-mock-service]: https://github.com/bethesque/pact-mock_service
[pact-mock-service-without-ruby]: https://github.com/DiUS/pact-consumer-js-dsl/wiki/Using-the-Pact-Mock-Service-without-Ruby