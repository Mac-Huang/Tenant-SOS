import SwiftUI
import CoreSpotlight
import CoreData

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var selectedState: String = "All States"
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var locationManager: LocationManager

    let categories = ["All", "Tenant Rights", "Traffic Laws", "Employment", "Consumer Rights", "Tax Laws"]

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)

                FilterBar(selectedCategory: $selectedCategory, selectedState: $selectedState)

                if searchText.isEmpty {
                    PopularSearchesView()
                } else {
                    SearchResultsView(searchText: searchText, category: selectedCategory, state: selectedState)
                }

                Spacer()
            }
            .navigationTitle("Search Laws")
        }
        .onAppear {
            indexSearchableContent()
        }
    }

    private func indexSearchableContent() {
        let laws = dataController.fetchLaws(for: locationManager.currentState ?? "CA")

        for law in laws {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
            attributeSet.title = law.title
            attributeSet.contentDescription = law.lawDescription

            let item = CSSearchableItem(
                uniqueIdentifier: law.objectID.uriRepresentation().absoluteString,
                domainIdentifier: "com.tenantsos.laws",
                attributeSet: attributeSet
            )

            CSSearchableIndex.default().indexSearchableItems([item]) { error in
                if let error = error {
                    print("Indexing error: \\(error.localizedDescription)")
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search laws, rights, documents...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FilterBar: View {
    @Binding var selectedCategory: String
    @Binding var selectedState: String

    let categories = ["All", "Tenant Rights", "Traffic Laws", "Employment"]
    let states = ["All States", "CA", "TX", "NY", "FL", "IL"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Menu {
                    ForEach(categories, id: \\.self) { category in
                        Button(category) {
                            selectedCategory = category
                        }
                    }
                } label: {
                    Label(selectedCategory, systemImage: "line.3.horizontal.decrease.circle")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                Menu {
                    ForEach(states, id: \\.self) { state in
                        Button(state) {
                            selectedState = state
                        }
                    }
                } label: {
                    Label(selectedState, systemImage: "location")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PopularSearchesView: View {
    let popularSearches = [
        "Security deposit return",
        "Eviction notice requirements",
        "Rent increase limits",
        "Tenant repair responsibilities",
        "Breaking lease early",
        "Landlord entry rights"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Searches")
                .font(.headline)
                .padding(.horizontal)

            ForEach(popularSearches, id: \\.self) { search in
                Button(action: {
                    // Handle popular search tap
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.gray)
                        Text(search)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.top)
    }
}

struct SearchResultsView: View {
    let searchText: String
    let category: String
    let state: String
    @EnvironmentObject var dataController: DataController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(filteredLaws, id: \\.self) { law in
                    NavigationLink(destination: LawDetailView(law: law)) {
                        SearchResultRow(law: law, searchText: searchText)
                    }
                }
            }
            .padding()
        }
    }

    var filteredLaws: [Law] {
        let laws = dataController.fetchLaws(for: state == "All States" ? "" : state, category: category == "All" ? nil : category)

        if searchText.isEmpty {
            return laws
        }

        return laws.filter { law in
            (law.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (law.lawDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
}

struct SearchResultRow: View {
    let law: Law
    let searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(law.title ?? "")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(law.lawDescription ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Label(law.category?.name ?? "", systemImage: law.category?.icon ?? "folder")
                    .font(.caption2)
                    .foregroundColor(.blue)

                Spacer()

                Text(law.state?.code ?? "")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}