//
//  AddProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI

struct AddProductView: View {
    
    
    @State var ProductName: String = ""
    @State var ExpirationDate: String = ""
    @State var OpenedDate: String = ""
    
    
    
    @State var inputDate = Date()
    
    
    @State var productQuantity = 0
    @State var NotificationTime: Date = Date()
    @State var showPicker = false
    @State var textfailddate: String = "ExpirationDate"
    let startingDate:Date = Date()
    let endingDate:Date = Calendar.current.date(from: DateComponents(year: 10000)) ?? Date()
    // can't add an expired product.
    
    @State var value = ""
    var dropDownList = ["none", "3 months", "6 months", "9 months", "12 months"]
    
    @State var value2 = ""
    var dropDownList2 = ["Food", "Medicin", "Self Care"]
    
    @State var selection: String = "1 Day"
    let filterOption: [String] =
    ["1 Day", "5 days", "2 weeks"]
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
                VStack {
                    productImage
                    textFields
                    menus
                    additonInfo
                    addButton
                }
                .padding(.horizontal, 30)
            
            Group {
                if showPicker {
                    DatePicker("", selection: $inputDate, in: startingDate...endingDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .background(Color(uiColor: .systemGray5))
                }
            }
            
        }
        .navigationTitle("Add Product")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var productImage: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(uiColor: .systemGray5))
                .frame(width: 130)
            Image(systemName: "camera")
        }
        .padding(.bottom)
    }
    
    var textFields: some View {
        VStack(spacing: 25) {
            CustomText(label: "Product Name", text: $ProductName)
            CustomText(label: "ExpirationDate", text: $ExpirationDate)
                .onTapGesture {
                    textfailddate = "ExpirationDate"
                    showPicker.toggle()
                }
                .onChange(of: inputDate, perform: { _ in
                    
                    // Create Date Formatter
                    let dateFormatter = DateFormatter()
                    
                    // Set Date Format
                    dateFormatter.dateFormat = "dd/MM/YY"
                    if textfailddate == "ExpirationDate" {
                        ExpirationDate = dateFormatter.string(from: inputDate)
                    } else {
                        OpenedDate = dateFormatter.string(from: inputDate)
                    }
                    if !showPicker {
                        inputDate = Date()
                    }
                    
                    
                })
            
            // Opened Date Feild
            CustomText(label: "Opened Date", text: $OpenedDate)
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
                    ForEach(dropDownList, id: \.self){ client in
                        Button(client) {
                            self.value = client
                        }
                    }
                } label: {
                    VStack(spacing: 10){
                        HStack{
                            Text(value.isEmpty ? "none" : value)
                                .foregroundColor(value.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.black)
                                .font(Font.system(size: 20, weight: .bold))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(10)
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
                    ForEach(dropDownList2, id: \.self){ client in
                        Button(client) {
                            self.value2 = client
                        }
                    }
                } label: {
                    VStack(spacing: 10){
                        HStack{
                            Text(value2.isEmpty ? "selecct product category" : value2)
                                .foregroundColor(value2.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.black)
                                .font(Font.system(size: 20, weight: .bold))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(10)
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
                    selection: $selection,
                    label: Text(selection),
                    content: {
                        ForEach(filterOption, id: \.self) { option in
                            Text(option)
                                .tag(option)
                        }
                    }
                    
                )
                .background(Color(uiColor: .systemGray5)).cornerRadius(12)
            }
            
            // Notification Time Picker
            DatePicker("Notification Time", selection: $NotificationTime, displayedComponents: .hourAndMinute)
                .bold()
                .font(.subheadline)
        }
    }
    
    var addButton: some View {
        Button {
             
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
        NavigationView {
            AddProductView()
        }
    }
}
