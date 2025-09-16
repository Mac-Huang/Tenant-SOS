import SwiftUI
import StoreKit

struct ProUpgradeView: View {
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ProHeaderSection()

                    ProFeaturesSection()

                    PricingSection(
                        products: storeManager.products,
                        selectedProduct: $selectedProduct
                    )

                    if let product = selectedProduct {
                        PurchaseButton(
                            product: product,
                            isPurchasing: $isPurchasing,
                            storeManager: storeManager
                        )
                    }

                    RestoreButton(storeManager: storeManager)

                    LegalText()
                }
                .padding()
            }
            .navigationTitle("Upgrade to Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProHeaderSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Unlock Full Access")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Get unlimited features and support")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
}

struct ProFeaturesSection: View {
    let features = [
        ("Unlimited Documents", "Generate unlimited legal documents every month", "doc.text.fill"),
        ("All States Access", "Access laws for all 50 states, not just the initial 5", "map.fill"),
        ("Priority Updates", "Get law updates as soon as they're available", "bolt.fill"),
        ("Advanced Search", "Search across all categories and states", "magnifyingglass.circle.fill"),
        ("Export Options", "Export documents in multiple formats", "square.and.arrow.up.fill"),
        ("No Ads", "Enjoy an ad-free experience", "xmark.shield.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pro Features")
                .font(.headline)
                .padding(.horizontal)

            ForEach(features, id: \\.0) { feature in
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: feature.2)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.0)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(feature.1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PricingSection: View {
    let products: [Product]
    @Binding var selectedProduct: Product?

    var body: some View {
        VStack(spacing: 12) {
            Text("Choose Your Plan")
                .font(.headline)

            ForEach(products, id: \\.id) { product in
                PricingOption(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    action: {
                        selectedProduct = product
                    }
                )
            }
        }
    }
}

struct PricingOption: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if product.id.contains("yearly") {
                        Text("Save 20%")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PurchaseButton: View {
    let product: Product
    @Binding var isPurchasing: Bool
    let storeManager: StoreManager

    var body: some View {
        Button(action: {
            Task {
                isPurchasing = true
                do {
                    _ = try await storeManager.purchase(product)
                    isPurchasing = false
                } catch {
                    isPurchasing = false
                }
            }
        }) {
            if isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Subscribe Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(Color.blue)
        .cornerRadius(12)
        .disabled(isPurchasing)
    }
}

struct RestoreButton: View {
    let storeManager: StoreManager
    @State private var isRestoring = false

    var body: some View {
        Button(action: {
            Task {
                isRestoring = true
                await storeManager.restorePurchases()
                isRestoring = false
            }
        }) {
            if isRestoring {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .disabled(isRestoring)
    }
}

struct LegalText: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Terms of Service", destination: URL(string: "https://tenantsos.com/terms")!)
                    .font(.caption2)

                Link("Privacy Policy", destination: URL(string: "https://tenantsos.com/privacy")!)
                    .font(.caption2)
            }
        }
        .padding(.top)
    }
}