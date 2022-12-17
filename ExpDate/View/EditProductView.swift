//
//  EditProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI

struct EditProductView: View {
    
    let product: ProductModel
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var productVM: ProductViewModel
    
    @State private var isPresentedScan = false
    
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

    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    productImage
                    textFields
                    menus
                    additonInfo
                    saveButton
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
            productName = product.name
            expirationDate = product.expirationDate
            openedDate = product.openDate
            //afterOpeningExpiration
            selectedCategory = ProductCategory(rawValue: product.productCategory)
            productQuantity = product.quantity
            //selectedRemindBefore
            notificationTime = product.notificationTime
            
        }
        .onChange(of: vm.expDate, perform: { newValue in
            if let expDate = vm.expDate {
                expirationDate = expDate.toDate()
                expirationDateStr = expirationDate.toString
            }
        })
        .navigationTitle("Edit Product")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(product: ProductModel.testProduct)
            .environmentObject(AppViewModel())
            .environmentObject(ProductViewModel())
    }
}

extension EditProductView {
    func updateProduct() {
        
        NotificationManager.shared.requestPermission()
        
        var productUpdated = ProductModel(
            id: product.id,
            imageurl: product.imageurl,
            name: productName,
            expirationDate: expirationDate,
            openDate: openedDate,
            afterOpeningExpiration: afterOpeningExpiration?.day ?? 0,
            productCategory: selectedCategory?.rawValue ?? ProductCategory.selfCare.rawValue,
            quantity: productQuantity,
            notificationTime: notificationTime,
            associatedRecord: product.associatedRecord
        )
        
        let notificationTime = calcNotificationTime(
            product: productUpdated,
            remindMeInDay: selectedRemindBefore.day)
        
        productUpdated.notificationTime = notificationTime ?? productUpdated.expiry
        
        productVM.updateProduct(updatedItem: productUpdated)
        
        // cancelNotification then selschedule Notification
        NotificationManager.shared.cancelNotification(for: productUpdated)
        NotificationManager.shared.scheduleNotification(for: productUpdated)
        
        // dismis
        dismiss()
        
        
    }
}

extension EditProductView {
    var productImage: some View {
        AsyncImage(url: URL(string: product.imageurl)) { image in
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
            CustomTextField(label: "Product Name", placeholder: product.name, text: $productName)
            CustomTextField(label: "Expiration Date", placeholder: product.expirationDate.toString, text: $expirationDateStr)
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
            CustomTextField(label: "Opened Date", placeholder: product.openDate.toString, text: $openedDateStr)
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
    
    var saveButton: some View {
        Button {
            updateProduct()
        } label: {
            Text("Save")
                .bold()
                .font(.title2)
                .frame(width: 330, height: 50)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .mask(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
}
