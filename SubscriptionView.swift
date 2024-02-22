import SwiftUI

struct SubscriptionView: View {
    @Binding var isVisible: Bool
    @Binding var isDemoExpired: Bool
    
    var body: some View {
        VStack {
            Text("Unlock to Full Acces")
                .font(.title)
                .padding()
            
            Text("Subscribe to access premium content and features!")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // Implement subscription purchase logic here
                // You would typically trigger the purchase process using StoreKit APIs provided by Apple
                // For the sake of this example, we'll just print a message
                print("Subscription purchase process triggered")
            }) {
                Text("Subscribe Now")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            
            Text("Terms: Subscription is charged monthly until canceled. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Your account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal. You can manage your subscriptions and turn off auto-renewal by going to your Apple subscriptions.")
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
    }
}

import SwiftUI

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
