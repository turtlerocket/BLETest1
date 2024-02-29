import Foundation
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, ObservableObject {
    
    static let shared = IAPManager()
    @Published var isTransactionSuccessful = false // Flag to indicate transaction success
    
    // Store fetched products
    @Published var products: [SKProduct] = []
    
    private override init() {
        super.init()
        
        SKPaymentQueue.default().add(self) // Add as transaction observer
        print("IAP Manager initialized")
    }
    
    func fetchProducts() {
        print("Fetching products...")
        let productIdentifiers: Set<String> = ["simplespinpurchase1"]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(_ product: SKProduct) {
        print("Initiating purchase for product: \(product.localizedTitle)")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        if products.isEmpty {
            print("No products found.")
        } else {
            print("Found \(products.count) product(s):")
            for product in products {
                print("Product: \(product.localizedTitle) - \(product.price)")
            }
            // Update the products property
            self.products = products
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products: \(error.localizedDescription)")
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Updating payment transactions...")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred, .purchasing:
                print("Transaction state: \(transaction.transactionState.rawValue)")
            @unknown default:
                print("Unknown transaction state encountered: \(transaction.transactionState.rawValue)")
            }
        }
    }
    
    func complete(transaction: SKPaymentTransaction) {
        print("Transaction completed successfully.")
        SKPaymentQueue.default().finishTransaction(transaction)
        
        // Set transaction success flag to true
               self.isTransactionSuccessful = true
    }
    
    func restore(transaction: SKPaymentTransaction) {
        print("Transaction restored successfully.")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func fail(transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            print("Transaction failed with error: \(error.localizedDescription)")
        } else {
            print("Transaction failed with no error message.")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
