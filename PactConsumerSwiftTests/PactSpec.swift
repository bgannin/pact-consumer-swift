import Quick
import Nimble
import PactConsumerSwift

class PactSpec: QuickSpec {

  override func spec() {

    describe("json") {
      let provider = "My Awesome Service"
      let consumer = "My Awesome App"
      let subject = Pact(provider: provider, consumer: consumer)

      it("returns the provider in payload") {
        let providerDict = subject.payload()["provider"]
        expect(providerDict?["name"]).to(equal(provider))
      }

      it("returns the consumer in consumer") {
        let consumerDict = subject.payload()["consumer"]
        expect(consumerDict?["name"]).to(equal(consumer))
      }

      it("includes pact version") {
        let metadata = subject.payload()["metadata"] as? [ String: [ String: String ] ]
        expect(metadata?["pact-specification"]?["version"]).to(equal("1.0.0"))
      }

      context("with interactions") {
        let interaction = Interaction()
        .uponReceiving("a request for an alligator")
        .withRequest(method:.GET, path: "/alligator")
        .willRespondWith(status: 200,
          headers: ["Content-Type": "application/json"],
          body: ["name": "Mary", "type": "alligator"])

        it("includes interaction") {
          subject.withInteractions([interaction])
          let interactions = subject.payload()["interactions"] as? [AnyObject]
          let firstInteraction = interactions?[0] as? [ String: AnyObject ]
          expect(firstInteraction?["description"] as? String).to(equal("a request for an alligator"))
        }
      }
    }
  }
}
