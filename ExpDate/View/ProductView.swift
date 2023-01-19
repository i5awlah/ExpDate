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
    
    @StateObject var productVM = ProductViewModel()
    @StateObject private var vm = AppViewModel()
    @State private var selectedProduct: ProductModel? = nil
    
    @State private var isPresentedScan = false
    @State private var isPresentedAddView = false
    @State private var showScannerStatusAlert = false
    @State private var scannerStatusAlertTitle = ""
    
    
    @State private var isSharing = false
    @State private var isProcessingShare = false

    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    // to delete product
    @State private var productDeleted: ProductModel?
    @State private var showingDeleteAlert = false
    
    // for add new list
    @State private var showAddListAlert = false
    @State private var listName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    categories
                        .padding(.top, 20)
                        contentView
                }
                
                addProductBottom
                    .opacity(productVM.isPrivateList ? 1 : 0)
                
                if isPresentedScan {
                    ScanProductView(isPresentedScan: $isPresentedScan, isPresentedAddView: $isPresentedAddView)
                }
                
                if productVM.accountStatus != .available {
                    Text("You must have an iCloud account\n to add products")
                        .multilineTextAlignment(.center)
                }
                
            }
            .sheet(isPresented: $isSharing, content: { shareView() })
            .sheet(item: $selectedProduct) { product in
                EditProductView(product: product)
            }
            .alert("List Name", isPresented: $showAddListAlert, actions: {
                TextField("List Name", text: $listName)
                Button("Add", action: {
                    if !listName.isEmpty {
                        Task {
                            productVM.addNewList(group: listName) {_, _ in
                                Task {
                                    try await productVM.refresh()
                                }
                            }
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
                    progressView
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    shareButton
                        .disabled(productVM.accountStatus != .available)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    listButton
                        .disabled(productVM.accountStatus != .available)
                }
            }
        }
        .alert(scannerStatusAlertTitle, isPresented: $showScannerStatusAlert, actions: {
            Button("continue without scan") {
                isPresentedAddView.toggle()
            }
        })
        .onChange(of: productVM.selectedCategory, perform: { _ in
            productVM.sortAndFilter()
        })
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
                            .foregroundColor(productVM.selectedCategory == category ? .accentColor : .primary)
                        
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
            ForEach(productVM.filterdProducts) { product in
                productRowView(for: product)
                    .frame(height: 80)
                    .onTapGesture {
                        selectedProduct = product
                    }
                    .swipeActions(content: {
                        Button(role: .none) { // make role as non to fix delete behavor
                            productDeleted = product
                            HapticManager.instance.notification(type: .warning)
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.red) // color of delete
                    })
            }
            .listRowSeparator(.hidden)
        }
        .alert("Are you sure to delete \(productDeleted?.name ?? "")?", isPresented: $showingDeleteAlert, actions: {
            Button("Cancel", role: .cancel, action: {})

            Button(role: .destructive) {
                if let productDeleted {
                    deleteProduct(productDeleted)
                }
            } label: {
                Text("Delete")
            }
        })
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
        ProductCellView(product: product)
    }
    
    var addProductBottom: some View {
        AddProductButtonView {
            isPresentedAddView.toggle()
        } scanButtonPressed: {
            scanButtonPressed()
        }
    }
    
    var shareButton: some View {
        Button {
            Task { try? await shareGroup(productVM.selectedGroup) }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .padding(8)
        }
        .opacity(productVM.isPrivateList ? 1 : 0)
    }
    
    /// This progress view will display when either the ViewModel is loading, or a share is processing.
    var progressView: some View {
        let showProgress: Bool = {
            if productVM.accountStatus != .available {
                return false
            } else if case .loading = productVM.state {
                return true
            } else if isProcessingShare {
                return true
            }

            return false
        }()

        return Group {
            if showProgress {
                ProgressView()
            }
        }
    }
    
    var listButton: some View {
        Button {
            self.isListActionSheetPresented.toggle()
        } label: {
            Image(systemName: "list.bullet")
                .padding(8)
        }
        .actionSheet(isPresented: $isListActionSheetPresented) {
            listActionSheet
        }
    }
    
    var listActionSheet: ActionSheet {
        var actionsheetButton: [ActionSheet.Button] = []
        
        for privateGroup in productVM.privateProducts {
            actionsheetButton.append(.default(Text(privateGroup.name), action: {
                productVM.selectedGroup = privateGroup
                productVM.isPrivateList = true
                Task {
                    try await productVM.refresh()
                }
            }))
        }
        
        for sharedGroup in productVM.sharedProducts {
            actionsheetButton.append(.default(Text(sharedGroup.name), action: {
                productVM.selectedGroup = sharedGroup
                productVM.isPrivateList = false
                Task {
                    try await productVM.refresh()
                }
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
        HapticManager.instance.notification(type: .warning)
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
    
    func deleteProduct(_ product: ProductModel) {
        productVM.deleteProduct(product.associatedRecord.recordID)
        Task {
            try await productVM.refresh()
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
    }
}
