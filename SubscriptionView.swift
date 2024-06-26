import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Binding var isVisible: Bool
    @Binding var isDemoExpired: Bool
    @State private var products: [SKProduct] = []
    @State private var errorMessage: String = ""
    
    @Binding var isWorking: Bool
    
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
                self.isWorking = true
                
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
            
            if isWorking {
                          ProgressView("Subscribing...")
                              .padding()
                      }
            
            // Display error message if no products found
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                            Text("Subscription Terms")
                                .font(.title)
                                .bold()

                            Text("Monthly Subscription:")
                                .font(.headline)
                            
                Text("• Subscription is charged $2.99 per month until canceled.")
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("• Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.")
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("• Your account will be charged for renewal within 24-hours prior to the end of the current period.")
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("• You can cancel at any time from your Apple account settings.")
                                    .fixedSize(horizontal: false, vertical: true)


                            Link("End-User License Agreement (EULA)", destination: URL(string: "https://simplespinapp.com/eula")!)
                                .font(.headline)

                            Link("Privacy Policy", destination: URL(string: "https://simplespinapp.com/privacy-policy")!)
                                .font(.headline)
                        }
                        .padding()

            
            if !isDemoExpired { // Check if demo is not expired
                Button(action: {
                    // Implement cancel subscription logic here
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
            
            // Server work call is done
            self.isWorking = false
            
            if success {
                // Clear error message
                self.errorMessage = ""


                print("Subscription transaction successful")
                // Transaction was successful, update subscription status or notify other managers/services
                
                // For example, if DemoExpirationManager is ObservableObject
                ExpirationManager.shared.setSubscription(isSubscribed: true)
                
                // Store isSubscribed with KeychainService
                KeychainService.shared.setIsSubscribed(true)
                
                // Set this View to be false
                self.isVisible = false
                
            }
            else {
                // Error message if subscription transaction fails
                self.errorMessage = "Please subscribe to unlock app."
                
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
            SubscriptionView(isVisible: .constant(true), isDemoExpired: .constant(false), isWorking: .constant(false))
                .previewLayout(.sizeThatFits)
                .padding()
            
            // Preview with Cancel button hidden
            SubscriptionView(isVisible: .constant(true), isDemoExpired: .constant(true),isWorking: .constant(false))
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
