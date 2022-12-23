//
//  addButtonView.swift
//  ExpDate
//
//  Created by Khawlah on 23/12/2022.
//

import SwiftUI

struct AddProductButtonView: View {
    // MARK: PROPERTIES
    let manuallyButtonPressed: () -> Void
    let scanButtonPressed: () -> Void
    @State var showPopUpAdding = false
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: BODY
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            
            
            VStack {
                Spacer()
                
                Button {
                    withAnimation() {
                        showPopUpAdding.toggle()
                    }
                } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .foregroundColor(colorScheme == .light ? .white : .black)
                                .frame(width: 30, height: 30)
                                .shadow(color: Color.secondary.opacity(0.7), radius: 2)
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30-6 , height: 30-6)
                                .foregroundColor(.accentColor)
                                .rotationEffect(Angle(degrees: showPopUpAdding ? 90 : 0))
                        }
                        
                        Text("Add product")
                    }
                    .font(.title3)
                }
                .padding(.top, 8)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorScheme == .light ? .clear : Color(uiColor: .systemGray6))
                .overlay(alignment: .top, content: {
                    Divider()
                })
                
            }
            if showPopUpAdding {
                VStack {
                    
                    ForEach(AddingType.allCases, id: \.hashValue) { addingType in
                        ZStack {
                            Circle()
                                .foregroundColor(.accentColor)
                                .frame(width: 48, height: 48)
                            Image(systemName: addingType.rawValue )
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(12)
                                .frame(width: 48, height: 48)
                                .foregroundColor(colorScheme == .light ? .white : .black)
                        }
                        .onTapGesture {
                            showPopUpAdding.toggle()
                            addingType == .barcode ? scanButtonPressed() : manuallyButtonPressed()
                        }
                    }
                        
                }
                .transition(.scale)
                .offset(y: -50)
                .padding(.leading)
            }
            
        }
        
    }
}

struct AddProductButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductButtonView(
            manuallyButtonPressed: {},
            scanButtonPressed: {})
    }
}

enum AddingType: String, CaseIterable {
    case manually = "square.and.pencil"
    case barcode = "barcode.viewfinder"
}
