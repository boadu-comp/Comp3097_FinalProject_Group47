//
//  ContentView.swift
//  Smartshopper
//
//  Created by Bakim Boadu on 2025-03-12.
//

import SwiftUI

struct Item: Identifiable, Codable {
    let id = UUID()
    var name: String
    var price: String
    var category: String
}

struct SavedData: Codable {
    var shoppingLists: [String]
    var categories: [String]
    var items: [Item]
}

// MARK: - ContentView

struct ContentView: View {
    
    @State private var shoppingLists: [String] = []
    @State private var categories: [String] = []
    @State private var items: [Item] = []
    @State private var taxRate: String = "10"
    
    // Calculate the total with tax
    var total: Double {
        let subtotal = items.compactMap { Double($0.price) }.reduce(0, +)
        let tax = subtotal * (Double(taxRate) ?? 0) / 100
        return subtotal + tax
    }
    
    var body: some View {
        NavigationView {
            launchScreen()
                .onAppear(perform: loadData)
                .onDisappear(perform: saveData)
        }
    }
    
    // MARK: - Screens / Views
    
    private func launchScreen() -> some View {
        VStack {
            Text("Smartshopper App")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("By Bakim Boadu")
                .font(.title2)
                .padding(.bottom, 40)
            
            NavigationLink(destination: homeScreen()) {
                Text("Enter App")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
    
    private func homeScreen() -> some View {
        List {
            Section(header: Text("Shopping Lists").font(.headline)) {
                ForEach(shoppingLists, id: \.self) { list in
                    NavigationLink(destination: shoppingListDetailScreen(listName: list)) {
                        Text(list)
                    }
                }
            }
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: settingsScreen()) {
                    Image(systemName: "gear")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    shoppingLists.append("New List")
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func shoppingListDetailScreen(listName: String) -> some View {
        VStack {
            List {
                ForEach($items) { $item in
                    HStack {
                        TextField("Item Name", text: $item.name)
                        TextField("Price", text: $item.price)
                            .keyboardType(.decimalPad)
                        Picker("Category", selection: $item.category) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }
            }
            
            Button("Add Item") {
                let defaultCategory = categories.first ?? ""
                items.append(Item(name: "", price: "", category: defaultCategory))
            }
            .padding()
            
            HStack {
                Text("Tax Rate:")
                TextField("Enter tax rate", text: $taxRate)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            Text("Total with Tax: $\(total, specifier: "%.2f")")
                .bold()
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Shopping List: \(listName)")
    }
    
    private func settingsScreen() -> some View {
        List {
            Section(header: Text("Manage Categories").font(.headline)) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Category") {
                    categories.append("New Category")
                }
            }
        }
    }
    
    // MARK: - Data Persistence 
    
    private func loadData() {
        if let savedData = PersistenceManager.shared.loadData(as: SavedData.self) {
            shoppingLists = savedData.shoppingLists
            categories = savedData.categories
            items = savedData.items
        } else {
            // Set default values if no saved data exists
            shoppingLists = ["Groceries", "Electronics"]
            categories = ["Food", "Electronics", "Clothing"]
            items = []
        }
    }
    
    private func saveData() {
        let savedData = SavedData(shoppingLists: shoppingLists, categories: categories, items: items)
        PersistenceManager.shared.saveData(savedData)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
