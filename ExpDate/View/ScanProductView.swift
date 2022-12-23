//
//  ScanProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI

struct ScanProductView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: AppViewModel
    
    @Binding var isPresentedScan: Bool
    @Binding var isPresentedAddView: Bool
    
    var body: some View {
        ZStack {
            mainView
            closeButton
            continueText
        }
        .onAppear{
            vm.recognizedItems = []
        }
        .navigationTitle("Scan")
        .toolbar(.hidden)
        
    }
    
}

extension ScanProductView {
    private var mainView: some View {
        DataScannerView(
            recognizedItems: $vm.recognizedItems,
            recognizedDataType: vm.recognizedDataType)
        .background { Color.gray.opacity(0.3) }
        .ignoresSafeArea()
        .id(vm.dataScannerViewId)
        .onAppear{
            vm.recognizedItems = []
        }
        .onChange(of: vm.scanType) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.recognizedText) { _ in handleRecognizedText() }
    }
    
    private var closeButton: some View {
        Button {
            withAnimation(.spring()) {
                isPresentedScan.toggle()
            }
        } label: {
            Image(systemName: "xmark.circle")
                .font(.title)
                .foregroundColor(.accentColor)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var continueText: some View {
        Button {
            isPresentedScan.toggle()
            isPresentedAddView.toggle()
        } label: {
            Text("Continue without scan?")
                .foregroundColor(.accentColor)
                .padding(8)
                .background(colorScheme == .light ? .white : .black)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding()
    }
}

extension ScanProductView {
    func handleRecognizedText() {
        print("handleRecognizedText..")
        if vm.recognizedText != nil {
            if vm.scanType == .barcode {
                print("barcode")
                // play a beeb sound when the barcode is recognized
                SoundManager.shared.playSound()
                
                // save recognized barcode on barcodeID
                vm.barcodeID = vm.recognizedText
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isPresentedScan.toggle()
                    isPresentedAddView.toggle()
                }
            } else {
                print("date")
                // save recognized barcode on date
                vm.expDate = vm.recognizedText
                // close
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isPresentedScan.toggle()
                }
            }
        }
    }
}

struct ScanProductView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScanProductView(isPresentedScan: .constant(false), isPresentedAddView: .constant(false))
                .environmentObject(AppViewModel())
        }
    }
}


