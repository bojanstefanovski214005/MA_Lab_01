//
//  ContentView.swift
//  MA_Lab
//
//  Created by Bojan Stefanovski on 26/03/2026.
//

import SwiftUI

struct ContentView: View {
    
    let grid = [
        ["AC", "DEL", "%", "/"],
        ["7", "8", "9", "X"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        [".", "0", "", "="]
    ]
    
    let operators = ["/", "+", "X", "%"]
    
    @State var visibleWorkings = ""
    @State var visibleResults = ""
    @State var showAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            Group {
                if isLandscape {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black.ignoresSafeArea())
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text(visibleWorkings),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // MARK: - Portrait Layout
    var portraitLayout: some View {
        VStack(spacing: 12) {
            displayView(workingsSize: 30, resultSize: 50)
            
            calculatorGrid(fontSize: 40)
        }
    }
    
    // MARK: - Landscape Layout
    var landscapeLayout: some View {
        HStack(spacing: 16) {
            displayView(workingsSize: 24, resultSize: 40)
                .frame(maxWidth: .infinity)
            
            calculatorGrid(fontSize: 28)
                .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Display
    func displayView(workingsSize: CGFloat, resultSize: CGFloat) -> some View {
        VStack(spacing: 10) {
            Spacer()
            
            HStack {
                Spacer()
                Text(visibleWorkings)
                    .font(.system(size: workingsSize, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            HStack {
                Spacer()
                Text(visibleResults)
                    .font(.system(size: resultSize, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding()
    }
    
    // MARK: - Grid
    func calculatorGrid(fontSize: CGFloat) -> some View {
        VStack(spacing: 10) {
            ForEach(grid, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { cell in
                        Button(action: {
                            buttonPressed(cell: cell)
                        }) {
                            Text(cell)
                                .foregroundColor(buttonColor(cell))
                                .font(.system(size: fontSize, weight: .heavy))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGray6).opacity(cell.isEmpty ? 0 : 0.08))
                                .cornerRadius(16)
                        }
                        .disabled(cell.isEmpty)
                    }
                }
            }
        }
    }
    
    // MARK: - Button Colors
    func buttonColor(_ cell: String) -> Color {
        if cell == "AC" || cell == "DEL" {
            return .red
        }
        
        if cell == "-" || cell == "=" || operators.contains(cell) {
            return .orange
        }
        
        return .white
    }
    
    // MARK: - Button Actions
    func buttonPressed(cell: String) {
        switch cell {
        case "AC":
            visibleWorkings = ""
            visibleResults = ""
        case "DEL":
            if !visibleWorkings.isEmpty {
                visibleWorkings = String(visibleWorkings.dropLast())
            }
        case "=":
            visibleResults = calculateResults()
        case "-":
            addMinus()
        case "X", "/", "%", "+":
            addOperator(cell)
        default:
            visibleWorkings += cell
        }
    }
    
    func addOperator(_ cell: String) {
        if !visibleWorkings.isEmpty {
            let last = String(visibleWorkings.last!)
            if operators.contains(last) || last == "-" {
                visibleWorkings.removeLast()
            }
            visibleWorkings += cell
        }
    }
    
    func addMinus() {
        if visibleWorkings.isEmpty || visibleWorkings.last! != "-" {
            visibleWorkings += "-"
        }
    }
    
    // MARK: - Calculation
    func calculateResults() -> String {
        if validInput() {
            var workings = visibleWorkings.replacingOccurrences(of: "%", with: "*0.01")
            workings = workings.replacingOccurrences(of: "X", with: "*")
            
            let expression = NSExpression(format: workings)
            
            if let result = expression.expressionValue(with: nil, context: nil) as? Double {
                return formatResult(val: result)
            }
        }
        
        showAlert = true
        return ""
    }
    
    func validInput() -> Bool {
        if visibleWorkings.isEmpty {
            return false
        }
        
        let last = String(visibleWorkings.last!)
        
        if operators.contains(last) || last == "-" {
            if last != "%" || visibleWorkings.count == 1 {
                return false
            }
        }
        
        return true
    }
    
    func formatResult(val: Double) -> String {
        if val.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", val)
        }
        return String(format: "%.2f", val)
    }
}

#Preview {
    ContentView()
}
