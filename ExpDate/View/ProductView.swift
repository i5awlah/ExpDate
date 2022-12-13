//
//  ProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI



struct ProductView: View {
    @State private var showListAlert : Bool = false
    @State private var isSheetPresented = false
    @State private var listName = ""
    
    
    @StateObject var productVM = ProductViewModel()
    @StateObject private var vm = AppViewModel()
    
    @State private var isPresentedScan = false
    @State private var isPresentedAddView = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    categories
                        .padding(.top, 20)
                    productList
                }
                
                scanButton
                    .padding(.trailing)
                
                if isPresentedScan {
                    ScanProductView(isPresentedScan: $isPresentedScan, isPresentedAddView: $isPresentedAddView)
                }
                
            }
            .actionSheet(isPresented: $isSheetPresented) {
                listActionSheet
            }
            .alert("List Name", isPresented: $showListAlert, actions: {
                TextField("List Name", text: $listName)
                Button("Add", action: {})
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Please enter the name of list.")
            })
            
            .navigationTitle("My List")
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
        .alert(alertTitle, isPresented: $showAlert, actions: {
            Button("continue without scan") {
                isPresentedAddView.toggle()
            }
        })
        .onChange(of: productVM.selectedCategory, perform: { _ in
            print("change")
            productVM.fetchProducts()
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
    
    var productList: some View {
        List {
            ForEach(productVM.products, id: \.recordId) { product in
                ProductCellView(product: product)
                    .listRowSeparator(.hidden)
                    .background(
                        NavigationLink("", destination: EditProductView(product: product))
                        .opacity(0)
                    )
            }
            .onDelete(perform: deleteProduct)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
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
        NavigationLink {
            MembersView()
        } label: {
            Image(systemName: "person.2.fill")
                .foregroundColor(.black)
        }
    }
    
    var listButton: some View {
        Button {
            self.isSheetPresented.toggle()
        } label: {
            Label("Lists", systemImage:"line.3.horizontal" )
                .foregroundColor(.black)
        }
    }
    
    var listActionSheet: ActionSheet {
        ActionSheet(title: Text("Choose a list") , message: Text("Choose existing list or create new list") , buttons: [
            .default(Text("My List"), action: {}),
            .default(Text("Family List") , action:{}),
            .default(Text("+ Add new list") , action:{
                showListAlert.toggle()
                
            }),
            .cancel()
            , ]
        )
    }
}

extension ProductView {
    
    func showAlert(_ title: String) {
        alertTitle = title
        showAlert.toggle()
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
        let item = productVM.products[index]
        if let recordId = item.recordId {
            productVM.deleteProduct(recordId)
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
    }
}
