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
    @State var expirationDateStr: String = ""
    @State var openedDateStr: String = ""
    
    @State var expirationDate: Date = .now
    @State var openedDate: Date = .now
    
    @State var inputDate = Date()
    
    @State var productQuantity = 1
    @State var notificationTime: Date = Date()
    @State var showPicker = false
    @State var textfailddate: String = "ExpirationDate"
    let startingDate:Date = Date()
    let endingDate:Date = Calendar.current.date(from: DateComponents(year: 10000)) ?? Date()
    // can't add an expired product.
    
    @State var afterOpeningExpiration: afterOpeningExpirationList? = nil
    @State var selectedCategory: ProductCategory? = nil
    @State var selectedRemindBefore: remindBefore = .oneDay
    
    // for the alert
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    productImage
                    textFields
                    menus
                    additonInfo
                    addButton
                }
                .padding(.horizontal, 30)
                .padding(.top)
            }
            
            
            if showPicker {
                DatePicker("", selection: $inputDate, in: startingDate...endingDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .background(Color(uiColor: .systemGray5))
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
                expirationDateStr = expirationDate.toString
            }
        })
        // show alert if there is an error while user enter inputs
        .alert(isPresented: $showAlert) {
            return Alert(title: Text(alertTitle))
        }
        .navigationTitle("Add Product")
        .navigationBarTitleDisplayMode(.inline)
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
    
    var textFields: some View {
        VStack(spacing: 25) {
            CustomTextField(label: "Product Name", placeholder: "", text: $productName)
            CustomTextField(label: "Expiration Date", placeholder: "", text: $expirationDateStr)
                .overlay(alignment: .trailing, content: {
                    Button {
                        vm.scanType = .text
                        withAnimation(.spring()) {
                            isPresentedScan.toggle()
                        }
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.headline)
                    }
                    .padding(.trailing)
                    
                })
                .onTapGesture {
                    textfailddate = "ExpirationDate"
                    showPicker.toggle()
                }
                .onChange(of: inputDate, perform: { _ in
                    
                    if textfailddate == "ExpirationDate" {
                        expirationDate = inputDate
                        expirationDateStr = inputDate.toString
                    } else {
                        openedDate = inputDate
                        openedDateStr = inputDate.toString
                    }
                    if !showPicker {
                        inputDate = Date()
                    }
                    
                    
                })
            
            // Opened Date Feild
            CustomTextField(label: "Opened Date", placeholder: "", text: $openedDateStr)
                .onTapGesture {
                    textfailddate = "Opened Date"
                    showPicker.toggle()
                }
        }
    }
    
    var menus: some View {
        VStack {
            // After Opening Expiration Menu
            VStack(spacing: 10) {
                Text("After Opening Expiration")
                    .bold()
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.black)
                                .font(Font.system(size: 20, weight: .bold))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 7)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(12)
            }
            
            // Product Category Menu
            VStack(spacing: 10) {
                Text("Product Category")
                    .bold()
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                            Text((selectedCategory?.rawValue) ?? "selecct product category")
                                .foregroundColor(selectedCategory == nil ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.black)
                                .font(Font.system(size: 20, weight: .bold))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 7)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    var additonInfo: some View {
        VStack(spacing: 20) {
            // Product Quantity Stepper
            Stepper("Product Quantity: \(productQuantity)", value: $productQuantity, in: 1...1000)
                .bold()
                .font(.subheadline)
            
            // Remined Me Befor Picker
            HStack{
                Text("Remined Me Before")
                    .bold()
                    .font(.subheadline)
                
                Spacer()
                Picker(
                    selection: $selectedRemindBefore,
                    label: Text(selectedRemindBefore.rawValue),
                    content: {
                        ForEach(remindBefore.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .tag(option)
                        }
                    }
                    
                )
                .background(Color(uiColor: .systemGray5)).cornerRadius(12)
            }
            
            // Notification Time Picker
            DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                .bold()
                .font(.subheadline)
        }
    }
    
    var addButton: some View {
        Button {
            addButtonPressed()
        } label: {
            Text("Add")
                .bold()
                .font(.title2)
                .frame(width: 330, height: 50)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .mask(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
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
            addProduct()
        }
    }
    
    func validateInputs() -> Bool {
        
        // should be fill product name
        guard !productName.isEmpty else {
            showAlert(title: "A product name must be provided.")
            return false
        }
        
        // should be fill expiration Date & opened Date
        guard !expirationDateStr.isEmpty else {
            showAlert(title: "An expiration Date must be provided.")
            return false
        }
        guard !openedDateStr.isEmpty else {
            showAlert(title: "An opened Date must be provided.")
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
            // dismis
            isPresentedAddView.toggle()
        }
        
    }
    
    func showAlert(title: String) {
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
