import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Binding var isVisible: Bool
    @Binding var isDemoExpired: Bool
    @State private var products: [SKProduct] = []
    @State private var errorMessage: String = ""
    
    @ObservedObject var iapManager = IAPManager.shared // Observed object to monitor transaction success
    
    
    var body: some View {
        VStack {
            Text("Unlock to Full Access")
                .font(.title)
                .padding()
            
            if (isDemoExpired) {
                Text("Demo is EXPIRED. Ensure uninterrupted access with your subscription! Enjoy seamless usage of all features!")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            else {
                Text("Ensure uninterrupted access with your subscription! Enjoy seamless usage of all features!")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                // Purchase subscription when button is tapped
                IAPManager.shared.fetchProducts()
                
            }) {
                Text("Subscribe Now")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            
            // Display error message if no products found
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Text("Terms: Subscription is charged monthly until canceled. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Your account will be charged for renewal within 24-hours prior to the end of the current period.  One can cancel at any time.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding()
            
            if !isDemoExpired { // Check if demo is not expired
                Button(action: {
                    // Implement cancel subscription logic here
                    // For the sake of this example, we'll just print a message
                    print("Cancel to not subscribe yet")
                    isVisible = false
                }) {
                    Text("Cancel")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onReceive(IAPManager.shared.$products) { fetchedProducts in
            self.products = fetchedProducts
            
            if fetchedProducts.isEmpty {
                self.errorMessage = "No products found."
            } else {
                // If products are found, initiate purchase with the first product
                IAPManager.shared.purchaseProduct(fetchedProducts[0])
            }
        }
        .onAppear {
            // Reset error message when view appears
            self.errorMessage = ""
        }
        
        .onReceive(iapManager.$isTransactionSuccessful) { success in
            if success {
                // Clear error message
                self.errorMessage = ""
                
                print("Subscription transaction successful")
                // Transaction was successful, update subscription status or notify other managers/services
                
                // For example, if DemoExpirationManager is ObservableObject
                DemoExpirationManager.shared.isSubscribed = true
                
                // Store isSubscribed with KeychainService
                KeychainService.shared.setIsSubscribed(true)
                
                // Set this View to be false
                self.isVisible = false
            }
            else {
                // Error message if subscription transaction fails
                self.errorMessage = "Unable to complete subscription transaction."
                
                // Set this View to be false
                self.isVisible = true
            }
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with Cancel button visible
            SubscriptionView(isVisible: .constant(true), isDemoExpired: .constant(false))
                .previewLayout(.sizeThatFits)
                .padding()
            
            // Preview with Cancel button hidden
            SubscriptionView(isVisible: .constant(true), isDemoExpired: .constant(true))
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
