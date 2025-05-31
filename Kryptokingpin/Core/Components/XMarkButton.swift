//
//  XMarkButton.swift
//  Kryptokingpin
//
//  Created by kingpin on 4/30/25.
//

import SwiftUI

struct XMarkButton: View {
    
    //@Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: {
         //presentationMode.wrappedValue.dismiss()
        dismiss()
     }, label: {
         Image(systemName: "xmark")
             
     })
    }
}

#Preview {
    XMarkButton()
}
