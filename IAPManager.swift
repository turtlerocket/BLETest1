import Foundation
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, ObservableObject {
    
    static let shared = IAPManager()
    @Published var isTransactionSuccessful = false // Flag to indicate transaction success
    
    // Store fetched products
    @Published var products: [SKProduct] = []
    
    @Published var isSubscribed = false // Add isSubscribed property
    
    
    private override init() {
        super.init()
        
        SKPaymentQueue.default().add(self) // Add as transaction observer
        print("IAP Manager initialized")
    }
    
    func fetchProducts() {
        print("Fetching products...")
        let productIdentifiers: Set<String> = ["standardsubscription1"]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(_ product: SKProduct) {
        print("Initiating purchase for product: \(product.localizedTitle)")
        
        let productPayment = SKPayment(product: product)
        
        
        // Add both the product and subscription to the payment queue
        SKPaymentQueue.default().add(productPayment)
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
        
        // Update subscription status after successful transaction
        checkSubscriptionStatus()
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
    
    // MARK: - Subscription Status Checking
    
    private func checkSubscriptionStatus() {
        print("Checking subscription status")
        // Your logic to check subscription status goes here
        self.isSubscribed = isSubscriptionValid(for: "standardsubscription1")          // Retrieve the app's receipt
    }
    
    func isSubscriptionValid(for productIdentifier: String) -> Bool {
        // Check if the user has a valid subscription for the given product identifier
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receiptURL.path) else {
            // No receipt found, subscription is invalid
            print("No receipt found, subscription is invalid")
            return false
        }
        
        do {
            // Load receipt data
            let receiptData = try Data(contentsOf: receiptURL)
            
            // Send receipt data to your server for validation
            // You should implement your server-side receipt validation logic here
            // After validating the receipt, determine if the subscription is valid
            print("Receipt data loaded successfully. Sending to server for validation...")
            
            // For demonstration purposes, let's assume the subscription is always valid
            return true
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return false
        }
    }

    
}
