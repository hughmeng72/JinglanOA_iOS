//
//  HtmlHelper.swift
//  PerkingOpera
//
//  Created by admin on 09/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//
import UIKit

class HtmlHelper {
    
    //    private func getHtmlLabel(text: String) -> UILabel {
    //        let label = UILabel()
    //        label.numberOfLines = 0
    //        label.lineBreakMode = .byWordWrapping
    //        label.attributedString = stringFromHtml(string: text)
    //        return label
    //    }
    
    static func stringFromHtml(string: String?) -> NSAttributedString? {
        do {
            let data = string?.data(using: String.Encoding.unicode, allowLossyConversion: true)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                 documentAttributes: nil)
                return str
            }
        } catch {
        }
        return nil
    }
    
}
