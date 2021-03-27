//
//  ContentView.swift
//  CoreDataPickerExample
//
//  Created by Dan Hancu on 26/03/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var items: FetchedResults<Item>
    @State private var selection: Item
    
    init(moc: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
        fetchRequest.predicate = NSPredicate(value: true)
        self._items = FetchRequest(fetchRequest: fetchRequest)
        do {
            let firstItem = try moc.fetch(fetchRequest)
            if(firstItem.count > 0) {
                self._selection = State(initialValue: firstItem.first!)
            } else {
                self._selection = State(initialValue: Item(context: moc))
                moc.delete(selection)
            }
        } catch {
            fatalError("Init Problem")
        }
    }
    
    var body: some View {
        VStack {
            if (items.count > 0) {
                Picker("Items", selection: $selection) {
                    ForEach(items) { (item: Item) in
                        Text(item.timestamp!, formatter: itemFormatter).tag(item)
                    }
                }.padding()
            }
            List {
                ForEach(items) { item in
                    Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            if (items.count > 0) {
                Text("Item \(selection.timestamp ?? Date(timeIntervalSince1970: 0), formatter: itemFormatter) is currently selected.").padding()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            do {
                try viewContext.save()
                selection = newItem //This automatically changes your selection when you add a new item.
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(moc: PersistenceController.preview.container.viewContext).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
