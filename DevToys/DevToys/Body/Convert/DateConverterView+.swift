//
//  DateConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import CoreUtil

final class DateConverterViewController: NSViewController {
    private let cell = DateConverterView()
    
    @Observable var date = Date()
    
    private let isoFormatter = ISO8601DateFormatter()
    private let gmtFormatter = DateFormatter() => {
        $0.locale = Locale(identifier: "en_US_POSIX")
        $0.timeZone = TimeZone(abbreviation: "GMT")
    }
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$date
            .sink{[unowned self] in
                self.cell.datePicker.date = $0
                self.cell.unixTimeField.value = $0.timeIntervalSince1970.rounded()
                self.cell.isoDateField.string = isoFormatter.string(from: $0)
                self.cell.graphicDatePicker.dateValue = $0
            }
            .store(in: &objectBag)
        
        self.cell.graphicDatePicker.actionPublisher
            .sink{[unowned self] in self.date = cell.graphicDatePicker.dateValue }.store(in: &objectBag)
        self.cell.nowButton.actionPublisher
            .sink{[unowned self] in self.date = Date() }.store(in: &objectBag)
        self.cell.datePicker.datePublisher
            .sink{[unowned self] in self.date = $0 }.store(in: &objectBag)
        self.cell.unixTimeField.valuePublisher
            .sink{[unowned self] in self.date = Date(timeIntervalSince1970: $0.reduce(self.date.timeIntervalSince1970)) }.store(in: &objectBag)
        self.cell.isoDateField.changeStringPublisher.compactMap{[unowned self] in isoFormatter.date(from: $0) }
            .sink{[unowned self] in self.date = $0 }.store(in: &objectBag)
    }
}

final private class DateConverterView: Page {
    
    let datePicker = DatePicker()
    let utcDatePicker = DatePicker()
    let nowButton = Button(title: "Now")
    let unixTimeField = NumberField()
    let isoDateField = TextField(showCopyButton: false)
    let graphicDatePicker = NSDatePicker()
    
    override func onAwake() {        
        self.addSection(Section(title: "Date".localized(), items: [
            NSStackView() => {
                $0.distribution = .equalSpacing
                $0.addArrangedSubview(datePicker)
                $0.addArrangedSubview(nowButton)
            }
        ]))
        self.datePicker.snp.remakeConstraints{ make in
            make.right.equalTo(nowButton.snp.left).inset(-8)
        }
        
        self.addSection(Section(title: "Unix Time".localized(), items: [unixTimeField]))
        self.unixTimeField.showStepper = false
        self.unixTimeField.snp.remakeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        self.addSection(Section(title: "ISO 8601".localized(), items: [isoDateField]))
        
        self.addSection(Section(title: "Calender".localized(), items: [graphicDatePicker]))
        self.graphicDatePicker.datePickerStyle = .clockAndCalendar
    }
}

