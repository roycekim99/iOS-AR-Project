//
//  View+Extensions.swift
//  TableTop
//
//  Created by Jet Aung on 2/2/22.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
