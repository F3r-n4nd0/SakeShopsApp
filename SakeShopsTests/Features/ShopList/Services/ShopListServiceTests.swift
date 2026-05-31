import Testing
import Foundation
@testable import SakeShops

@Suite("ShopListService")
struct ShopListServiceTests {
    @Test func fetchShops_returnsShops_onSuccess() async throws {
        let stub = StubHTTPClient()
        stub.result = .success(makeSakeShopsData(count: 3))
        let service = await ShopListService(client: stub)

        let shops = try await service.fetchShops()
        #expect(shops.count == 3)
    }

    @Test func fetchShops_throwsDecodingFailed_onInvalidJSON() async throws {
        let stub = StubHTTPClient()
        stub.result = .success(Data("invalid".utf8))
        let service = await ShopListService(client: stub)

        do {
            _ = try await service.fetchShops()
            Issue.record("Expected ShopListError.decodingFailed to be thrown")
        } catch ShopListError.decodingFailed {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func fetchShops_throwsFetchFailed_onNetworkError() async throws {
        let stub = StubHTTPClient()
        stub.result = .failure(.invalidResponse)
        let service = await ShopListService(client: stub)

        do {
            _ = try await service.fetchShops()
            Issue.record("Expected ShopListError.fetchFailed to be thrown")
        } catch ShopListError.fetchFailed {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func fetchShops_throwsFetchFailed_onStatusCodeError() async throws {
        let stub = StubHTTPClient()
        stub.result = .failure(.statusCode(503, Data()))
        let service = await ShopListService(client: stub)

        do {
            _ = try await service.fetchShops()
            Issue.record("Expected ShopListError.fetchFailed to be thrown")
        } catch ShopListError.fetchFailed(let networkError) {
            if case .statusCode(let code, _) = networkError {
                #expect(code == 503)
            } else {
                Issue.record("Expected statusCode error, got \(networkError)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
