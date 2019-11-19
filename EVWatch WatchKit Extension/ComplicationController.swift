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
        handler(NSDate(timeIntervalSinceNow: 10))
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
        if complication.family == .circularSmall {
            // these values should be fetched from somewhere...
            let progress = self.getSoc()
            let template = CLKComplicationTemplateCircularSmallRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: self.getSocStr())
            
            if progress < 15 { headerTextProvider.tintColor = .red }
            else if progress < 30 { headerTextProvider.tintColor = .orange }
            else if progress < 50 { headerTextProvider.tintColor = .yellow }
            else {
                headerTextProvider.tintColor =  .green
            }
            
            template.textProvider = headerTextProvider
            template.fillFraction = Float(progress) / 100
            template.ringStyle = CLKComplicationRingStyle.closed
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
            handler(timelineEntry)
        } else if ( complication.family == .modularSmall) {
            
            let progress = self.getSoc()
            let template = CLKComplicationTemplateModularSmallRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: self.getSocStr())
            
            if progress < 15 { headerTextProvider.tintColor = .red }
            else if progress < 30 { headerTextProvider.tintColor = .orange }
            else if progress < 50 { headerTextProvider.tintColor = .yellow }
            else {
                headerTextProvider.tintColor =  .green
            }
            
            template.textProvider = headerTextProvider
            template.fillFraction = Float(progress) / 100
            template.ringStyle = CLKComplicationRingStyle.closed
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate() as Date, complicationTemplate: template)
            handler(timelineEntry)
            
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
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family{
        case .modularSmall:
            let modularSmallTemplate = CLKComplicationTemplateModularSmallRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: "75")
            headerTextProvider.tintColor = .green
            
            modularSmallTemplate.textProvider = headerTextProvider
            modularSmallTemplate.fillFraction = 0.75
            modularSmallTemplate.ringStyle = CLKComplicationRingStyle.closed
            handler(modularSmallTemplate)
            break;
        case .circularSmall:
            let modularSmallTemplate = CLKComplicationTemplateCircularSmallRingText()
            let headerTextProvider = CLKSimpleTextProvider(text: "75")
            headerTextProvider.tintColor = .green
            
            modularSmallTemplate.textProvider = headerTextProvider
            modularSmallTemplate.fillFraction = 0.75
            modularSmallTemplate.ringStyle = CLKComplicationRingStyle.closed
            handler(modularSmallTemplate)
            break;
        default:
            handler(nil)
        }


    }
    
}
