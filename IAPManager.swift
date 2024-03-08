import Foundation
import StoreKit

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
        
        // Call isSubscriptionValid function to check subscription status
        isSubscriptionValid(for: "standardsubscription1") { isValid in
            // Handle the result of the subscription validation
            DispatchQueue.main.async {
                self.isSubscribed = isValid
            }
        }
    }
    
    func isSubscriptionValid(for productIdentifier: String, completion: @escaping (Bool) -> Void) {
        // Check if the user has a valid subscription for the given product identifier
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            // No receipt found, subscription is invalid
            print("No receipt found, subscription is invalid")
            completion(false)
            return
        }
        
        debugPrint("Receipt URL: \(receiptURL)")
        
        do {
            let receiptData = try Data(contentsOf: receiptURL)
            let receiptString = receiptData.base64EncodedString()
            
            var requestDictionary: [String: Any] = ["receipt-data": receiptString]
            // Add your shared secret to the request dictionary
            requestDictionary["password"] = "8166c870463f4bbe926db3953a7e46b2"
            
            let requestData = try JSONSerialization.data(withJSONObject: requestDictionary, options: [])
            
            debugPrint("Receipt receiptData: \(receiptData)")
            
            // Send the receipt data to Apple's validation server
            // Switch between sandbox and production URLs based on build configuration
#if DEBUG
            let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"
#else
            let validationURLString = "https://buy.itunes.apple.com/verifyReceipt"
#endif
            
            //            let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt" // or "https://buy.itunes.apple.com/verifyReceipt" for production
            guard let validationURL = URL(string: validationURLString) else {
                print("Invalid validation URL")
                completion(false)
                return
            }
            
            var request = URLRequest(url: validationURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error validating receipt: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    completion(false)
                    return
                }
                
                do {
                    guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        print("Invalid JSON response")
                        completion(false)
                        return
                    }
                    
                    print("Receipt validation response status: \(jsonResponse["status"])")
                    
                    // Example parsing: Check if the status field indicates the subscription is active
                    if let status = jsonResponse["status"] as? Int, status == 0 {
                        print("Server Subscription valid and active!")
                        
                        // Status 0 usually indicates an active subscription
                        completion(true)
                    } else {
                        // Subscription is not active or status not found
                        completion(false)
                    }
                } catch {
                    print("Error parsing receipt validation response: \(error.localizedDescription)")
                    completion(false)
                }
            }
            
            task.resume()
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func openSubscriptionManagement(completion: @escaping (Bool) -> Void) {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("Opened App Store for subscription management")
                } else {
                    print("Failed to open App Store for subscription management")
                }
            }
        }
    }
}
