//
//  ProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI
import CloudKit

struct ProductView: View {
    @State private var isListActionSheetPresented = false
    @State private var isPrivateList = true
    
    @StateObject var productVM = ProductViewModel()
    @StateObject private var vm = AppViewModel()
    
    @State private var isPresentedScan = false
    @State private var isPresentedAddView = false
    @State private var showScannerStatusAlert = false
    @State private var scannerStatusAlertTitle = ""
    
    
    @State private var isSharing = false
    @State private var isProcessingShare = false

    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    @State private var showingDeleteAlert = false
    
    // for add new list
    @State private var showAddListAlert = false
    @State private var listName = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    categories
                        .padding(.top, 20)
                    contentView
                    Spacer()
                }
                
                scanButton
                    .padding(.trailing)
                    .opacity(isPrivateList ? 1 : 0)
                
                if isPresentedScan {
                    ScanProductView(isPresentedScan: $isPresentedScan, isPresentedAddView: $isPresentedAddView)
                }
                
            }
            .sheet(isPresented: $isSharing, content: { shareView() })
            .actionSheet(isPresented: $isListActionSheetPresented) {
                listActionSheet
            }
            .alert("List Name", isPresented: $showAddListAlert, actions: {
                TextField("List Name", text: $listName)
                Button("Add", action: {
                    if !listName.isEmpty {
                        Task {
                            try await productVM.addNewList(group: listName)
                            try await productVM.refresh()
                            listName = ""
                        }
                    }
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Please enter the name of list.")
            })
            
            .navigationTitle(productVM.selectedGroup.name)
            .navigationDestination(isPresented: $isPresentedAddView) {
                AddProductView(isPresentedAddView: $isPresentedAddView)
        }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    shareButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    listButton
                }
            }
        }
        .alert(scannerStatusAlertTitle, isPresented: $showScannerStatusAlert, actions: {
            Button("continue without scan") {
                isPresentedAddView.toggle()
            }
        })
        .onAppear {
            Task {
                try await productVM.refresh()
            }
        }
        .environmentObject(vm)
        .environmentObject(productVM)
    }
}

extension ProductView {
    var categories: some View {
        HStack(spacing: 0) {
            Spacer()
            ForEach(ProductCategory.allCases, id: \.rawValue) { category in
                Button(action: {
                    withAnimation{
                        productVM.selectedCategory = category
                    }
                }, label: {
                    
                    VStack(spacing:12){
                        Text(category.rawValue)
                            .foregroundColor(productVM.selectedCategory == category ? .accentColor : .black)
                        
                        Capsule()
                            .fill(productVM.selectedCategory == category ? Color.accentColor : Color.clear)
                            .frame(height:1.2)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                })
                Spacer()
            }
            
        }
        .overlay(alignment: .bottom){
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .frame(height:1.2)
        }
    }
    
    private var contentView: some View {
        List {
            if isPrivateList {
                if productVM.selectedCategory == .all {
                    ForEach(productVM.selectedGroup.products.sorted(by: { $0.expiry < $1.expiry })) { product in
                        productRowView(for: product)
                    }
                    .onDelete(perform: deleteProduct)
                } else {
                    ForEach(productVM.selectedGroup.products.sorted(by: { $0.expiry < $1.expiry }).filter({ $0.productCategory == productVM.selectedCategory.rawValue })) { product in
                        productRowView(for: product)
                    }
                    .onDelete(perform: deleteProduct)
                }
                
                
            } else {
                
                if productVM.selectedCategory == .all {
                    ForEach(productVM.selectedGroup.products.sorted(by: { $0.expiry < $1.expiry })) { product in
                        productRowView(for: product)
                    }
                } else {
                    ForEach(productVM.selectedGroup.products.sorted(by: { $0.expiry < $1.expiry }).filter({ $0.productCategory == productVM.selectedCategory.rawValue })) { product in
                        productRowView(for: product)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .refreshable {
            Task {
                try await productVM.refresh()
            }
        }
    }
    
    /// Builds a `CloudSharingView` with state after processing a share.
    private func shareView() -> CloudSharingView? {
        guard let share = activeShare, let container = activeContainer else {
            return nil
        }

        return CloudSharingView(container: container, share: share)
    }
    
    private func productRowView(for product: ProductModel) -> some View {
        HStack {
            ProductCellView(product: product)
                .listRowSeparator(.hidden)
                .background(
                    NavigationLink("", destination: EditProductView(product: product))
                    .opacity(0)
                )
        }
    }
    
    var scanButton: some View {
        Button {
            scanButtonPressed()
        } label: {
            Circle()
                .fill(Color.accentColor)
                .frame(width:82 , height:82)
                .overlay(){
                    Image(systemName: "barcode.viewfinder")
                        .foregroundColor(Color.white)
                        .font(.system(size: 30))
                }
                
        }
    }
    
    var shareButton: some View {
        Button {
            Task { try? await shareGroup(productVM.selectedGroup) }
        } label: {
            Image(systemName: "person.2.fill")
                .foregroundColor(.black)
        }
        .opacity(isPrivateList ? 1 : 0)
    }
    
    var listButton: some View {
        Button {
            self.isListActionSheetPresented.toggle()
        } label: {
            Label("Lists", systemImage:"line.3.horizontal" )
                .foregroundColor(.black)
        }
    }
    
    var listActionSheet: ActionSheet {
        var actionsheetButton: [ActionSheet.Button] = []
        
        if productVM.privateProducts.count == 0 {
            actionsheetButton.append(.default(Text(productVM.selectedGroup.name), action: {
                isPrivateList = true
            }))
        }

        for privateGroup in productVM.privateProducts {
            actionsheetButton.append(.default(Text(privateGroup.name), action: {
                productVM.selectedGroup = privateGroup
                isPrivateList = true
            }))
        }
        
        for sharedGroup in productVM.sharedProducts {
            actionsheetButton.append(.default(Text(sharedGroup.name), action: {
                productVM.selectedGroup = sharedGroup
                isPrivateList = false
            }))
        }
        
        actionsheetButton.append(.default(Text("+ Add new list"), action: { showAddListAlert = true }))
        actionsheetButton.append(.cancel())
        
        return ActionSheet(
            title: Text("Choose a list") ,
            message: Text("Choose existing list or create new list") ,
            buttons: actionsheetButton
        )
    }
}

extension ProductView {
    
    // MARK: - Actions

    private func shareGroup(_ productGroup: ProductGroup) async throws {
        isProcessingShare = true

        do {
            let (share, container) = try await productVM.fetchOrCreateShare(productGroup: productGroup)
            isProcessingShare = false
            activeShare = share
            activeContainer = container
            isSharing = true
        } catch {
            debugPrint("Error sharing product record: \(error)")
        }
    }
    
    func showAlert(_ title: String) {
        scannerStatusAlertTitle = title
        showScannerStatusAlert.toggle()
    }
    
    func scanButtonPressed() {
        Task {
            await vm.requestDataScannerAccessStatus()
            
            switch vm.dataScannerAccessStatus {
            case .scannerAvailable:
                vm.scanType = .barcode
                withAnimation(.spring()) {
                    isPresentedScan.toggle()
                }
            case .cameraNotAvailable:
                showAlert("Your device doesn't have a camera")
            case .scannerNotAvailable:
                showAlert("Your device doesn't have support for scanning barcode with this app")
            case .cameraAccessNotGranted:
                showAlert("Please provide access to the camera in settings")
            case .notDetermined:
                showAlert("Requesting camera access")
            }
        }
    }
    
    func deleteProduct(_ indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let item = productVM.selectedGroup.products[index]
        productVM.deleteProduct(item.associatedRecord.recordID)
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
    }
}
