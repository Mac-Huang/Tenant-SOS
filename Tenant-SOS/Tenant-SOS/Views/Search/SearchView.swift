import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var selectedState: String = "All States"
    @State private var recentSearches: [String] = []
    @State private var searchWorkItem: DispatchWorkItem?
    
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: performSearch)

                FilterBar(
                    selectedCategory: $selectedCategory,
                    selectedState: $selectedState,
                    categories: ["All"] + dataController.getCategories(),
                    states: ["All States"] + dataController.fetchStates().map { $0.abbreviation }
                )

                if searchText.isEmpty {
                    PopularSearchesView(onSearchTap: { search in
                        searchText = search
                        performSearch(search)
                    })
                } else {
                    SearchResultsView(
                        searchText: searchText,
                        category: selectedCategory,
                        state: selectedState
                    )
                }

                Spacer()
            }
            .navigationTitle("Search Laws")
        }
        .onAppear {
            loadRecentSearches()
        }
        .onChange(of: searchText) { newValue in
            // Cancel previous work item
            searchWorkItem?.cancel()
            
            // Create new work item with delay
            let workItem = DispatchWorkItem {
                performSearch(newValue)
            }
            
            searchWorkItem = workItem
            
            // Execute after delay to debounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
    }

    private func performSearch(_ text: String) {
        // Add to recent searches
        if !text.isEmpty && !recentSearches.contains(text) {
            recentSearches.insert(text, at: 0)
            if recentSearches.count > 10 {
                recentSearches.removeLast()
            }
            saveRecentSearches()
        }
    }

    private func loadRecentSearches() {
        if let searches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearches = searches
        }
    }

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: (String) -> Void
    @State private var isEditing = false

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search laws, rights, documents...", text: $text, onCommit: {
                    onSearch(text)
                })
                .foregroundColor(.primary)
                .onTapGesture {
                    isEditing = true
                }

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if isEditing {
                Button("Cancel") {
                    isEditing = false
                    text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isEditing)
            }
        }
        .padding(.horizontal)
    }
}

struct FilterBar: View {
    @Binding var selectedCategory: String
    @Binding var selectedState: String
    let categories: [String]
    let states: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Category filter
                Menu {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack {
                                Text(category)
                                if selectedCategory == category {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(selectedCategory)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }

                // State filter
                Menu {
                    ForEach(states, id: \.self) { state in
                        Button(action: {
                            selectedState = state
                        }) {
                            HStack {
                                Text(state == "All States" ? state : getStateName(for: state))
                                if selectedState == state {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "location")
                        Text(selectedState == "All States" ? selectedState : getStateName(for: selectedState))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }

    private func getStateName(for code: String) -> String {
        if code == "All States" { return code }
        return code // In production, map to full state name
    }
}

struct PopularSearchesView: View {
    let onSearchTap: (String) -> Void
    @State private var recentSearches: [String] = []

    let popularSearches = [
        "Security deposit return",
        "Eviction notice requirements",
        "Rent increase limits",
        "Minimum wage",
        "Overtime pay",
        "Speed limits",
        "DUI penalties",
        "Breaking lease early",
        "Landlord entry rights",
        "Workers compensation"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recent searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                            Spacer()
                            Button("Clear") {
                                clearRecentSearches()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)

                        ForEach(recentSearches.prefix(5), id: \.self) { search in
                            SearchSuggestionRow(
                                text: search,
                                icon: "clock",
                                onTap: { onSearchTap(search) }
                            )
                        }
                    }
                }

                // Popular searches
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Searches")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(popularSearches, id: \.self) { search in
                        SearchSuggestionRow(
                            text: search,
                            icon: "magnifyingglass",
                            onTap: { onSearchTap(search) }
                        )
                    }
                }
            }
            .padding(.top)
        }
        .onAppear {
            loadRecentSearches()
        }
    }

    private func loadRecentSearches() {
        if let searches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearches = searches
        }
    }

    private func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
}

struct SearchSuggestionRow: View {
    let text: String
    let icon: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                Text(text)
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

struct SearchResultsView: View {
    let searchText: String
    let category: String
    let state: String
    @EnvironmentObject var dataController: DataController
    @State private var filteredLaws: [LawModel] = []
    @State private var isSearching = false

    var body: some View {
        ScrollView {
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    if filteredLaws.isEmpty {
                        NoResultsView(searchText: searchText)
                    } else {
                        Text("\(filteredLaws.count) results found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        LazyVStack(spacing: 8) {
                            ForEach(filteredLaws, id: \.id) { law in
                                NavigationLink(destination: LawDetailsView(law: law)) {
                                    SearchResultRow(law: law, searchText: searchText)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            performFilteringAsync()
        }
        .onChange(of: searchText) { _ in
            performFilteringAsync()
        }
        .onChange(of: category) { _ in
            performFilteringAsync()
        }
        .onChange(of: state) { _ in
            performFilteringAsync()
        }
    }

    private func performFilteringAsync() {
        isSearching = true
        
        Task {
            let result = await filterLawsAsync()
            await MainActor.run {
                self.filteredLaws = result
                self.isSearching = false
            }
        }
    }
    
    private func filterLawsAsync() async -> [LawModel] {
        return await Task.detached(priority: .userInitiated) {
            var laws: [LawModel] = []

            // Get laws based on state filter
            if state == "All States" {
                laws = dataController.laws
            } else {
                laws = dataController.fetchLaws(for: state)
            }

            // Filter by category
            if category != "All" {
                laws = laws.filter { $0.category == category }
            }

            // Filter by search text
            if !searchText.isEmpty {
                let lowercasedSearch = searchText.lowercased()
                laws = laws.filter { law in
                    law.title.lowercased().contains(lowercasedSearch) ||
                    law.summary.lowercased().contains(lowercasedSearch) ||
                    law.content.lowercased().contains(lowercasedSearch) ||
                    law.statute.lowercased().contains(lowercasedSearch)
                }
            }

            return laws
        }.value
    }
}

struct NoResultsView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No results found")
                .font(.headline)

            Text("No laws found matching '\(searchText)'")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Try adjusting your filters or search terms")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

struct SearchResultRow: View {
    let law: LawModel
    let searchText: String
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(law.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(highlightedSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if dataController.isBookmarked(law) {
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            HStack {
                Label(law.category, systemImage: getCategoryIcon(law.category))
                    .font(.caption2)
                    .foregroundColor(.blue)

                Spacer()

                Text(law.stateCode)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private var highlightedSummary: String {
        // In production, highlight the search term
        return law.summary
    }

    private func getCategoryIcon(_ category: String) -> String {
        switch category {
        case "Tenant Rights": return "house.fill"
        case "Traffic Laws": return "car.fill"
        case "Employment": return "briefcase.fill"
        default: return "folder.fill"
        }
    }
}

// LawDetailsView is defined in HomeView.swift