//
//  ComplicationController.swift
//  EVWatch WatchKit Extension
//
//  Created by EVSalomon on 06.11.19.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(NSDate() as Date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(NSDate() as Date)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        let token = UserDefaults.standard.string(forKey: "token")
        if ( token != nil ) {
            switch complication.family {
                case .circularSmall:
                    let progress = self.getSoc()
                    let template = CLKComplicationTemplateCircularSmallRingText()
                    let headerTextProvider = CLKSimpleTextProvider(text: self.getSocStr())
                    
                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                headerTextProvider.tintColor = .white
                                break;
                            case "1":
                                headerTextProvider.tintColor = .yellow
                                break;
                            case "2":
                                headerTextProvider.tintColor = .orange
                                break;
                            case "3":
                                headerTextProvider.tintColor = .red
                                break;
                            default:
                                headerTextProvider.tintColor = .white
                        }
                    } else {
                        headerTextProvider.tintColor = .white
                    }
                    
                    template.textProvider = headerTextProvider
                    template.fillFraction = Float(progress) / 100
                    template.ringStyle = CLKComplicationRingStyle.closed
                    
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                case .modularSmall:
                    let progress = self.getSoc()
                    let template = CLKComplicationTemplateModularSmallRingText()
                    let headerTextProvider = CLKSimpleTextProvider(text: self.getSocStr())
                    
                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                headerTextProvider.tintColor = .white
                                break;
                            case "1":
                                headerTextProvider.tintColor = .yellow
                                break;
                            case "2":
                                headerTextProvider.tintColor = .orange
                                break;
                            case "3":
                                headerTextProvider.tintColor = .red
                                break;
                            default:
                                headerTextProvider.tintColor = .white
                        }
                    } else {
                        headerTextProvider.tintColor = .white
                    }
                    
                    template.textProvider = headerTextProvider
                    template.fillFraction = Float(progress) / 100
                    template.ringStyle = CLKComplicationRingStyle.closed
                    
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                case .modularLarge:
                    let progress = self.getSoc()
                    let template = CLKComplicationTemplateModularLargeColumns();
                    
                    let col11TextProvider = CLKSimpleTextProvider(text: "SoC")
                    let col12TextProvider = CLKSimpleTextProvider(text: self.getSocDecStr()+"%")
                    
                    if progress < 15 { col11TextProvider.tintColor = .red }
                    else if progress < 30 { col11TextProvider.tintColor = .orange }
                    else if progress < 50 { col11TextProvider.tintColor = .yellow }
                    else {
                        col11TextProvider.tintColor =  .green
                    }
                    
                    template.row1Column1TextProvider = col11TextProvider
                    template.row1Column2TextProvider = col12TextProvider
                    
                    let col21TextProvider = CLKSimpleTextProvider(text: "Car")
                    let col22TextProvider = CLKSimpleTextProvider(text:self.getTimestamp())

                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                col21TextProvider.tintColor = .white
                                break;
                            case "1":
                                col21TextProvider.tintColor = .yellow
                                break;
                            case "2":
                                col21TextProvider.tintColor = .orange
                                break;
                            case "3":
                                col21TextProvider.tintColor = .red
                                break;
                            default:
                                col21TextProvider.tintColor = .white
                        }
                    } else {
                        col21TextProvider.tintColor = .white
                    }
                                        
                    template.row2Column1TextProvider = col21TextProvider
                    template.row2Column2TextProvider = col22TextProvider
                    
                    let col31TextProvider = CLKSimpleTextProvider(text: "Watch")
                    let col32TextProvider = CLKSimpleTextProvider(text:self.getActTimestamp())
                    
                    
                                
                    template.row3Column1TextProvider = col31TextProvider
                    template.row3Column2TextProvider = col32TextProvider
                    
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                case .utilitarianSmall:
                    let progress = self.getSoc()
                    let template = CLKComplicationTemplateUtilitarianSmallRingText()
                    let headerTextProvider = CLKSimpleTextProvider(text: self.getSocStr())
                    
                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                headerTextProvider.tintColor = .white
                                break;
                            case "1":
                                headerTextProvider.tintColor = .yellow
                                break;
                            case "2":
                                headerTextProvider.tintColor = .orange
                                break;
                            case "3":
                                headerTextProvider.tintColor = .red
                                break;
                            default:
                                headerTextProvider.tintColor = .white
                        }
                    } else {
                        headerTextProvider.tintColor = .white
                    }
                    
                    template.textProvider = headerTextProvider
                    template.fillFraction = Float(progress) / 100
                    template.ringStyle = CLKComplicationRingStyle.closed
                    
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                case .extraLarge:
                    let progress = self.getSoc()
                    let template = CLKComplicationTemplateExtraLargeRingText()
                    let headerTextProvider = CLKSimpleTextProvider(text: self.getSocDecStr())
                    
                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                headerTextProvider.tintColor = .white
                                break;
                            case "1":
                                headerTextProvider.tintColor = .yellow
                                break;
                            case "2":
                                headerTextProvider.tintColor = .orange
                                break;
                            case "3":
                                headerTextProvider.tintColor = .red
                                break;
                            default:
                                headerTextProvider.tintColor = .white
                        }
                    } else {
                        headerTextProvider.tintColor = .white
                    }
                    
                    template.textProvider = headerTextProvider
                    template.fillFraction = Float(progress) / 100
                    template.ringStyle = CLKComplicationRingStyle.closed
                    
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                case .graphicCorner:
                    let progress = self.getSoc()
                    
                    let template = CLKComplicationTemplateGraphicCornerGaugeText()
                    let outerTextProvider = CLKSimpleTextProvider(text: self.getSocDecStr() + "%")
                    let leadingTextProvider = CLKSimpleTextProvider(text: "0")
                    let trailingTextProvider = CLKSimpleTextProvider(text: "100")
                    
                    template.outerTextProvider = outerTextProvider
                    template.leadingTextProvider = leadingTextProvider
                    template.trailingTextProvider = trailingTextProvider
                    
                    var gaugeProvider:CLKSimpleGaugeProvider
                    
                    
                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
                                break;
                            case "1":
                                gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: Float(progress) / 100)
                                break;
                            case "2":
                                gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .orange, fillFraction: Float(progress) / 100)
                                break;
                            case "3":
                                gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .red, fillFraction: Float(progress) / 100)
                                break;
                            default:
                                gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
                        }
                    } else {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
                    }
                    /*
                    if progress < 15 {
                        
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .red, fillFraction: Float(progress) / 100)
                        
                    }
                    else if progress < 30 {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .orange, fillFraction: Float(progress) / 100)
                        
                    }
                    else if progress < 50 {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: Float(progress) / 100)
                    }
                    else {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
                    }
                    */
                    template.gaugeProvider = gaugeProvider
                    
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                case .graphicCircular:
                    let progress = self.getSoc()
                    
                    let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
                    let centerTextProvider = CLKSimpleTextProvider(text: self.getSocStr())
                    
                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                centerTextProvider.tintColor = .white
                                break;
                            case "1":
                                centerTextProvider.tintColor = .yellow
                                break;
                            case "2":
                                centerTextProvider.tintColor = .orange
                                break;
                            case "3":
                                centerTextProvider.tintColor = .red
                                break;
                            default:
                                centerTextProvider.tintColor = .white
                        }
                    } else {
                        centerTextProvider.tintColor = .white
                    }
                                
                    template.centerTextProvider = centerTextProvider

                    var gaugeProvider:CLKSimpleGaugeProvider
                    
                    if progress < 15 {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .red, fillFraction: Float(progress) / 100)
                    }
                    else if progress < 30 {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .orange, fillFraction: Float(progress) / 100)
                    }
                    else if progress < 50 {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: Float(progress) / 100)
                    }
                    else {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
                    }
                    
                    template.gaugeProvider = gaugeProvider
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                case .graphicBezel:
                    let template = CLKComplicationTemplateGraphicBezelCircularText()
                    let centerTextProviderTop = CLKSimpleTextProvider(text: self.getTimestampLong())
                    
                    let check = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                centerTextProviderTop.tintColor = .white
                                break;
                            case "1":
                                centerTextProviderTop.tintColor = .yellow
                                break;
                            case "2":
                                centerTextProviderTop.tintColor = .orange
                                break;
                            case "3":
                                centerTextProviderTop.tintColor = .red
                                break;
                            default:
                                centerTextProviderTop.tintColor = .white
                        }
                    } else {
                        centerTextProviderTop.tintColor = .white
                    }
                                
                    template.textProvider = centerTextProviderTop
                                        
                    let progress = self.getSoc()
                    
                    let templateCircular = CLKComplicationTemplateGraphicCircularClosedGaugeText()
                    let centerTextProvider = CLKSimpleTextProvider(text: self.getSocStr())
                    
                    let check_timestampcolor = UserDefaults.standard.string(forKey: "timestampColor")
                    if ( check_timestampcolor != nil ) {
                        let colorCode = UserDefaults.standard.string(forKey: "timestampColor")!
                        switch(colorCode){
                            case "0":
                                centerTextProvider.tintColor = .white
                                break;
                            case "1":
                                centerTextProvider.tintColor = .yellow
                                break;
                            case "2":
                                centerTextProvider.tintColor = .orange
                                break;
                            case "3":
                                centerTextProvider.tintColor = .red
                                break;
                            default:
                                centerTextProvider.tintColor = .white
                        }
                    } else {
                        centerTextProvider.tintColor = .white
                    }
                                
                    templateCircular.centerTextProvider = centerTextProvider
                                
                    var gaugeProvider:CLKSimpleGaugeProvider
                    
                    if progress < 15 {
                        
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .red, fillFraction: Float(progress) / 100)
                        
                    }
                    else if progress < 30 {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .orange, fillFraction: Float(progress) / 100)
                        
                    }
                    else if progress < 50 {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: Float(progress) / 100)
                    }
                    else {
                        gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
                    }
                    templateCircular.gaugeProvider = gaugeProvider
                    template.circularTemplate = templateCircular
                    let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
                    handler(timelineEntry)
                    break;
                default:
                    handler(nil)
                    break;
            }
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler([])
    }
    
    func getSocStr() -> String{
        let check = UserDefaults.standard.string(forKey: "soc")
        if ( check != nil ) {
            var soc_str = UserDefaults.standard.string(forKey: "soc")!
            var soc = Double(soc_str) ?? 0.0
            soc = soc.rounded(.down)
            let soc_ns = soc as NSNumber
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0

            soc_str = formatter.string(from: soc_ns) ?? "0"
            return soc_str
        } else {
            return "0"
        }
    }
    
    func getSocDecStr() -> String{
        let check = UserDefaults.standard.string(forKey: "soc")
        if ( check != nil ) {
            var soc_str = UserDefaults.standard.string(forKey: "soc")!
            let soc = Double(soc_str) ?? 0.0
            let soc_ns = soc as NSNumber
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            soc_str = formatter.string(from: soc_ns) ?? "0"
            return soc_str
        } else {
            return "0"
        }
    }
    
    func getSoc() -> Double{
        let check = UserDefaults.standard.string(forKey: "soc")
        if ( check != nil ) {
            let soc_str = UserDefaults.standard.string(forKey: "soc")!
            let soc = Double(soc_str) ?? 0.0
            return soc
        } else {
            return 0.0
        }
    }
    
    func getTempStr() -> String{
        let check = UserDefaults.standard.string(forKey: "minTemp")
        if ( check != nil ) {
            let minTemp = UserDefaults.standard.string(forKey: "minTemp")!
            let maxTemp = UserDefaults.standard.string(forKey: "maxTemp")!
            let inletTemp = UserDefaults.standard.string(forKey: "inletTemp")!
            return minTemp + " / " + maxTemp + " / " + inletTemp
        } else {
            return "-"
        }
    }
    
    func getTimestamp() -> String{
        let check = UserDefaults.standard.string(forKey: "timestamp")
        if ( check != nil ) {
            let timestamp = UserDefaults.standard.string(forKey: "timestamp")!
            return timestamp
        }
        return "";
    }
    
    func getTimestampLong() -> String{
        let check = UserDefaults.standard.string(forKey: "timestampLong")
        if ( check != nil ) {
            let timestamp = UserDefaults.standard.string(forKey: "timestampLong")!
            return timestamp
        }
        return "";
    }
    
    func getActTimestamp() -> String{
        let check = UserDefaults.standard.string(forKey: "timestampComp")
        if ( check != nil ) {
            let timestamp = UserDefaults.standard.string(forKey: "timestampComp")!
            return timestamp
        }
        return "";
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family{
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: "75")
            headerTextProvider.tintColor = .white
            
            template.textProvider = headerTextProvider
            template.fillFraction = 0.75
            template.ringStyle = CLKComplicationRingStyle.closed
            handler(template)
            break;
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: "75")
            headerTextProvider.tintColor = .white
            
            template.textProvider = headerTextProvider
            template.fillFraction = 0.75
            template.ringStyle = CLKComplicationRingStyle.closed
            handler(template)
            break;
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeColumns();
            
            let col11TextProvider = CLKSimpleTextProvider(text: "SoC")
            let col12TextProvider = CLKSimpleTextProvider(text: "75%")
            col11TextProvider.tintColor = .yellow
            
            
            
            template.row1Column1TextProvider = col11TextProvider
            template.row1Column2TextProvider = col12TextProvider
            
            
            let col21TextProvider = CLKSimpleTextProvider(text: "Car")
            col21TextProvider.tintColor = .white
            let col22TextProvider = CLKSimpleTextProvider(text:"10:09:00")
            template.row2Column1TextProvider = col21TextProvider
            template.row2Column2TextProvider = col22TextProvider
            
            let col31TextProvider = CLKSimpleTextProvider(text: "Watch")
            let col32TextProvider = CLKSimpleTextProvider(text:"10:09:00")
            
                        
            
            template.row3Column1TextProvider = col31TextProvider
            template.row3Column2TextProvider = col32TextProvider
    
            handler(template)
            break;
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: "75")
            headerTextProvider.tintColor = .white
            
            template.textProvider = headerTextProvider
            template.fillFraction = 0.75
            template.ringStyle = CLKComplicationRingStyle.closed
            handler(template)
            break;
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: "75")
            headerTextProvider.tintColor = .white
            
            template.textProvider = headerTextProvider
            template.fillFraction = 0.75
            template.ringStyle = CLKComplicationRingStyle.closed
            handler(template)
            
            break;
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            let outerTextProvider = CLKSimpleTextProvider(text: "75%")
            let leadingTextProvider = CLKSimpleTextProvider(text: "0")
            let trailingTextProvider = CLKSimpleTextProvider(text: "100")
            
            template.outerTextProvider = outerTextProvider
            template.leadingTextProvider = leadingTextProvider
            template.trailingTextProvider = trailingTextProvider
            
            let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: 0.75)
            
            /*let gaugeProvider = CLKGaugeProvider(gaugeColor:.yellow, fillFraction:0.75)*/
            template.gaugeProvider = gaugeProvider
            handler(template)
            break;
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            let centerTextProvider = CLKSimpleTextProvider(text: "75")
            template.centerTextProvider = centerTextProvider
           
            let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: 0.75)
            
            /*let gaugeProvider = CLKGaugeProvider(gaugeColor:.yellow, fillFraction:0.75)*/
            template.gaugeProvider = gaugeProvider
            handler(template)
            
            break;
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            let centerTextProviderTop = CLKSimpleTextProvider(text: "01.01.2020 10:09:00")
            centerTextProviderTop.tintColor = .white
            template.textProvider = centerTextProviderTop
            
            let progress = 75
            
            let templateCircular = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            let centerTextProvider = CLKSimpleTextProvider(text: "75")
                        
            centerTextProvider.tintColor = .white
                       
            templateCircular.centerTextProvider = centerTextProvider
                        
            //let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
            var gaugeProvider:CLKSimpleGaugeProvider
            gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: Float(progress) / 100)
            templateCircular.gaugeProvider = gaugeProvider
            
            template.circularTemplate = templateCircular
            
            handler(template)
            break;
        default:
            handler(nil)
        }
    }
}
