//
//  AddProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI
import CloudKit

struct AddProductView: View {
    
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var productVM: ProductViewModel
    @StateObject private var productApiViewModel = ProductAPIViewModel()
    
    @State private var isPresentedScan = false
    @Binding var isPresentedAddView: Bool
    
    @State var productName: String = ""
    
    @State var expirationDate: Date = .now
    @State var openedDate: Date = .now
    
    @State var productQuantity = 1
    @State var notificationTime: Date = Date()
    
    let startingDate:Date = Date()
    let endingDate:Date = Calendar.current.date(from: DateComponents(year: 10000)) ?? Date()
    // can't add an expired product.
    
    @State var afterOpeningExpiration: afterOpeningExpirationList? = nil
    @State var selectedCategory: ProductCategory? = nil
    @State var selectedRemindBefore: remindBefore = .oneDay
    
    // for the alert
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    @State var addingloaded = false
    
    
    var body: some View {
        
        ZStack {
            
            Form {
                VStack {
                    productImage
                    
                    CustomTextField(label: "Product Name", placeholder: "", text: $productName)
                        .padding(.bottom)
                }
                expirationDateField
                openDateField
                afterOpeningExpirationMenu
                productCategoryMenu
                productQuantityStepper
                reminedMeBeforPicker
                notificationTimePicker
            }
            
            if isPresentedScan {
                ScanProductView(isPresentedScan: $isPresentedScan, isPresentedAddView: .constant(false))
            }
            
        }
        .onAppear{
            print("onAppear: \(vm.barcodeID ?? "NA")")
            guard let id = vm.barcodeID else { return }
            productApiViewModel.getProductAPI(productID: id)
        }
        .onChange(of: productApiViewModel.isFeaching, perform: { _ in
            if productApiViewModel.isFeaching {
                productName = productApiViewModel.product.title
                self.selectedCategory = productApiViewModel.product.toExistingCategory()
            }
        })
        .onChange(of: vm.expDate, perform: { newValue in
            if let expDate = vm.expDate {
                expirationDate = expDate.toDate()
            }
        })
        // show alert if there is an error while user enter inputs
        .alert(isPresented: $showAlert) {
            return Alert(title: Text(alertTitle))
        }
        .navigationTitle("Add Product")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                progressView
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    addButtonPressed()
                }
                .disabled(productVM.accountStatus != .available)
            }
        }
    }
    
    /// This progress view will display when either the ViewModel is loading, or a share is processing.
    var progressView: some View {
        let showProgress: Bool = {
            if productApiViewModel.isLoading {
                return true
            } else if addingloaded {
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
    
    var productImage: some View {
        AsyncImage(url: URL(
            string: productApiViewModel.product.images.isEmpty ? "" : productApiViewModel.product.images[0]
        )
        ) { image in
            ZStack {
                image
                    .resizable()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(.gray, lineWidth: 1))
            }
        } placeholder: {
            ZStack {
                Circle()
                    .foregroundColor(Color(uiColor: .systemGray5))
                    .frame(width: 130)
                Image(systemName: "camera")
            }
        }
        .padding(.bottom)
    }
    
    var expirationDateField: some View {
        DatePicker(
            "Expiration Date",
            selection: $expirationDate,
            in: startingDate...endingDate,
            displayedComponents: .date)
        .overlay(alignment: .leading) {
            Button {
                vm.scanType = .text
                withAnimation(.spring()) {
                    isPresentedScan.toggle()
                }
            } label: {
                Image(systemName: "barcode.viewfinder")
                    .font(.title3)
            }
            .padding(.leading, 125)
        }
        .padding(.vertical, 2)
    }
    
    var openDateField: some View {
        DatePicker("Opened Date", selection: $openedDate, displayedComponents: .date)
        .padding(.vertical, 2)
    }
    
    var afterOpeningExpirationMenu: some View {
        HStack(spacing: 10) {
            Text("After Opening Expiration")
                .bold()
                .font(.subheadline)
            Spacer()
            Menu {
                ForEach(afterOpeningExpirationList.allCases, id: \.self) { item in
                    Button(item.rawValue) {
                        self.afterOpeningExpiration = item
                    }
                }
            } label: {
                VStack(spacing: 10){
                    HStack{
                        Text(afterOpeningExpiration?.rawValue ?? "none")
                            .foregroundColor((afterOpeningExpiration == nil) ? .gray : .black)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.black)
                            .font(Font.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 7)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(12)
        }
        .padding(.vertical, 2)
    }
    
    var productCategoryMenu: some View {
        HStack(spacing: 10) {
            Text("Product Category")
                .bold()
                .font(.subheadline)
            Spacer()
            Menu {
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    if category != .all {
                        Button(category.rawValue) {
                            self.selectedCategory = category
                        }
                    }
                }
            } label: {
                VStack(spacing: 10){
                    HStack{
                        Text((selectedCategory?.rawValue) ?? "none")
                            .foregroundColor(selectedCategory == nil ? .gray : .black)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.black)
                            .font(Font.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 7)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(12)
        }
        .padding(.vertical, 2)
    }
    
    var productQuantityStepper: some View {
        Stepper("Product Quantity: \(productQuantity)", value: $productQuantity, in: 1...1000)
            .bold()
            .font(.subheadline)
            .padding(.vertical, 2)
    }
    
    var reminedMeBeforPicker: some View {
        HStack {
            Text("Remined Me Before")
                .bold()
                .font(.subheadline)
            
            Spacer()
            Picker(
                selection: $selectedRemindBefore,
                label: Text(""),
                content: {
                    ForEach(remindBefore.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
                
            )
        }
    }
    
    var notificationTimePicker: some View {
        DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
            .bold()
            .font(.subheadline)
            .padding(.vertical, 2)
    }
}


struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddProductView(isPresentedAddView: .constant(false)) // "0846566555284"
                .environmentObject(AppViewModel())
                .environmentObject(ProductViewModel())
        }
    }
}

extension AddProductView {
    
    func addButtonPressed() {
        if validateInputs() {
            addingloaded = true
            addProduct()
        }
    }
    
    func validateInputs() -> Bool {
        
        // should be fill product name
        guard !productName.isEmpty else {
            showAlert(title: "A product name must be provided.")
            return false
        }
        
        // should be fill product category
        guard (selectedCategory != nil) else {
            showAlert(title: "A product category must be provided.")
            return false
        }
        
        return true
    }
    
    func addProduct() {
        
        NotificationManager.shared.requestPermission()
        
        let imageurl = productApiViewModel.product.images.isEmpty ? "" : productApiViewModel.product.images[0]
        
        var newProduct = ProductModel(
            id: UUID().uuidString,
            imageurl: imageurl,
            name: productName,
            expirationDate: expirationDate,
            openDate: openedDate,
            afterOpeningExpiration: afterOpeningExpiration?.day ?? 0,
            productCategory: selectedCategory?.rawValue ?? ProductCategory.selfCare.rawValue,
            quantity: productQuantity,
            notificationTime: notificationTime,
            associatedRecord: CKRecord(recordType: "Product")
        )
        
        let notificationTime = calcNotificationTime(
            product: newProduct,
            remindMeInDay: selectedRemindBefore.day)
        
        newProduct.notificationTime = notificationTime ?? newProduct.expiry
        
        print("Product\n : \(newProduct)")
        
        Task {
            try await productVM.addProduct(product: newProduct, group: productVM.selectedGroup.name)
            try await productVM.refresh()
            // schedule Notification
            NotificationManager.shared.scheduleNotification(for: newProduct)
        }
        
        addingloaded = false
        // dismis
        isPresentedAddView.toggle()
        
    }
    
    func showAlert(title: String) {
        HapticManager.instance.notification(type: .warning)
        alertTitle = title
        showAlert.toggle()
    }
}

func calcNotificationTime(product: ProductModel, remindMeInDay: Int) -> Date? {
    // get hour and minute from notificationTime
    let hour = Calendar.current.component(.hour, from: product.notificationTime)
    let minute = Calendar.current.component(.minute, from: product.notificationTime)
    
    // subtract remindMeInDay days from expiry date
    guard let dateOfRemind = Calendar.current.date(byAdding: .day, value: -remindMeInDay, to: product.expiry) else { return nil }
    // change only time
    let dateAndTimeOfRemind = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: dateOfRemind)
    return dateAndTimeOfRemind
}

enum afterOpeningExpirationList: String, CaseIterable {
    case none = "none"
    case three = "3 months"
    case six = "6 months"
    case nine = "9 months"
    case twelve = "12 months"
    
    var day: Int {
        switch self {
        case .none:
            return 0
        case .three:
            return 3 * 30
        case .six:
            return 6 * 30
        case .nine:
            return 9 * 30
        case .twelve:
            return 12 * 30
        }
    }
}

enum remindBefore: String, CaseIterable {
    case oneDay = "1 Day"
    case fiveDays = "5 days"
    case twoWeek = "2 weeks"
    
    var day: Int {
        switch self {
        case .oneDay:
            return 1
        case .fiveDays:
            return 5
        case .twoWeek:
            return 14
        }
    }
}
