//
//  OnoardingView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI


enum OnbordingType: CaseIterable {
    case scan
    case track
    case remind
    case share
    
    var image: String {
        switch self {
        case .scan:
            return "scan"
        case .track:
            return "track"
        case .remind:
            return "reminder"
        case .share:
            return "share"
        }
    }
    
    var title: String {
        switch self {
        case .scan:
            return "Scan"
        case .track:
            return "Track"
        case .remind:
            return "Remind"
        case .share:
            return "Share"
        }
    }
    
    var description: String {
        switch self {
        case .scan:
            return "Scan any product barcode with easiest way."
        case .track:
            return "Track your products validity through colors to get the most benefit of it!"
        case .remind:
            return "Enable notification to get reminder in your chosen time."
        case .share:
            return "Share products details with any one to keep track of all expiry date products."
        }
    }
}


struct OnbordingView: View {
    
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    @State var selectedOnbordingType: OnbordingType = .scan
    
    var body: some View {
        ZStack {
            
            TabView(selection: $selectedOnbordingType) {
                
                ForEach(OnbordingType.allCases, id: \.title) { onbording in
                    SingleOnbordingView(onbordingType: onbording)
                        .tag(onbording)
                        .onChange(of: selectedOnbordingType, perform: { newValue in
                            selectedOnbordingType = newValue
                        })
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            if selectedOnbordingType != .share {
                skipButton
            }
        }
        .onAppear {
            setupAppearance()
        }
    }
}

struct OnbordingView_Previews: PreviewProvider {
    static var previews: some View {
        OnbordingView()
    }
}

extension OnbordingView {
    var skipButton: some View {
        Button {
            withAnimation(.spring()) {
                isUserOnboarded = true
            }
        } label: {
            Text("skip")
                .padding(10)
        }
        .padding(.top, 1)
        .padding(.trailing ,30)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(maxHeight: .infinity, alignment: .top)
        .foregroundColor(.secondary)
    }
}

extension OnbordingView {
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
}

