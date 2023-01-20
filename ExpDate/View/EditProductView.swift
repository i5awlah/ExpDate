//
//  EditProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI
import CloudKit

struct EditProductView: View {
    
    let product: ProductModel
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var productVM: ProductViewModel
    
    @State private var isPresentedScan = false
    @State private var isPresentedCancelAlert = false
    
    @State var productName: String = ""
    @State var expirationDate: Date = .now
    @State var openedDate: Date = .now
        
    @State var productQuantity = 1
    @State var notificationTime: Date = Date()
    
    @State var afterOpeningExpiration: afterOpeningExpirationList? = nil
    @State var selectedCategory: ProductCategory? = nil
    @State var selectedRemindBefore: remindBefore = .oneDay
    
    // for Image Picker
    @State var selectedImage: UIImage?
    @State var didSet: Bool = false
    @State private var showingImagePicker = false

    
    var body: some View {
        NavigationStack {
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
                productName = product.name
                expirationDate = product.expirationDate
                openedDate = product.openDate
                afterOpeningExpiration = fromDay(day: product.afterOpeningExpiration)
                selectedCategory = ProductCategory(rawValue: product.productCategory)
                productQuantity = product.quantity
                //selectedRemindBefore
                notificationTime = product.notificationTime
                
            }
            .onChange(of: vm.expDate, perform: { newValue in
                if let expDate = vm.expDate {
                    expirationDate = expDate.toDate()
                    vm.expDate = nil
                }
            })
            .alert("Are you sure you want to discard your changes?", isPresented: $isPresentedCancelAlert, actions: {
                Button("Keep Editing", role: .cancel, action: {})

                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Discard Changes")
                }
            })
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        NotificationManager.shared.requestPermission()
                        handleImage()
                    }
                    .disabled(!isChenge())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        // dismis
                        if isChenge() {
                            HapticManager.instance.notification(type: .warning)
                            isPresentedCancelAlert.toggle()
                        } else {
                            dismiss()
                        }
                        
                    } label: {
                        Text("Cancel")
                    }
                }
                
                
            }
        }
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
    
    var productImage: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(.gray, lineWidth: 1))
            } else {
                if product.imageurl.isEmpty && product.imageURL == nil {
                    ZStack {
                        Circle()
                            .foregroundColor(Color(uiColor: .systemGray5))
                            .frame(width: 130)
                        Image(systemName: "camera")
                    }
                    
                } else {
                    
                    if product.imageURL != nil {
                        AsyncImage(url: product.imageURL) { image in
                            ZStack {
                                image
                                    .resizable()
                                    .scaledToFill()
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
                                ProgressView()
                            }
                        }
                    } else {
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
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture {
            showingImagePicker.toggle()
        }
        .padding(.bottom)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, didSet: $didSet, sourceType: .photoLibrary)
        }
        


    }
    
    var expirationDateField: some View {
        DatePicker(
            "Expiration Date",
            selection: $expirationDate,
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
                            .foregroundColor((afterOpeningExpiration == nil) ? .gray : .primary)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.primary)
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
                            .foregroundColor(selectedCategory == nil ? .gray : .primary)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.primary)
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

extension EditProductView {
    
    func fromDay(day: Int) -> afterOpeningExpirationList {
        switch(day) {
        case 0: return .none
        case 90: return .three
        case 180: return .six
        case 270: return .nine
        case 360: return .twelve
        default:
            return .none
        }
    }
    
    func handleImage() {
        
        var returnedCKAsset: CKAsset?
        // check if user upload photo
        if selectedImage != nil {
            Task {
                returnedCKAsset = try await convertUIImageToCKAsset()
                
                var productUpdated = ProductModel(
                    id: product.id,
                    imageurl: product.imageurl,
                    imageURL: (selectedImage != nil) ? returnedCKAsset?.fileURL : nil,
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
                
                updateProduct(productUpdated: productUpdated)
            }
        } else {
            var productUpdated = ProductModel(
                id: product.id,
                imageurl: product.imageurl,
                imageURL: nil,
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
            
            updateProduct(productUpdated: productUpdated)
        }
    }
    
    func updateProduct(productUpdated: ProductModel) {
        
        productVM.updateProduct(updatedItem: productUpdated)
        
        // cancelNotification then selschedule Notification
        NotificationManager.shared.cancelNotification(for: productUpdated)
        NotificationManager.shared.scheduleNotification(for: productUpdated)
        
        // dismis
        dismiss()
        
        
    }
    
    func convertUIImageToCKAsset() async throws -> CKAsset? {
        guard
            let imageURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(UUID().uuidString).jpg"),
            let data = selectedImage?.jpegData(compressionQuality: 1.0) else { return nil}
        
        do {
            try data.write(to: imageURL)
            let asset = CKAsset(fileURL: imageURL)
            return asset
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func isChenge() -> Bool {
        if productName == product.name
            && expirationDate == product.expirationDate
            && openedDate == product.openDate
            && afterOpeningExpiration == fromDay(day: product.afterOpeningExpiration)
            && selectedCategory == ProductCategory(rawValue: product.productCategory)
            && productQuantity == product.quantity
            && notificationTime == product.notificationTime
            && selectedImage == nil {
            return false
        } else {
            return true
        }
    }
}
