//
//  SoapHelper.swift
//  PerkingOpera
//
//  Created by admin on 02/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Foundation

class SoapHelper {
//    private static let host = "http://192.168.9.31/"                              // Debug in Home
    private static let host = "http://test.freight-track.com/"                      // Dedug in ECNU
//    private static let host = "http://www.jjyoa.com:8000/"                        // Production
    
//    private static let requestUrl = "\(host)WebUI/WebService/Perkingopera.asmx"   // Debug in Home
    private static let requestUrl = "\(host)WebService/Perkingopera.asmx"           // Production or ECNU
    
//    static let uploadUrl = "\(host)WebUI/WebService/Pages/UploadPhoto.aspx"       // Debug in Home
    static let uploadUrl = "\(host)WebService/Pages/UploadPhoto.aspx"             // Production or ECNU
    
    
    static func getURLRequest(method: String, parameters: String) -> URLRequest {
        let bodyString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
            "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" " +
            "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">" +
            "<soap:Body>" +
            "<\(method) xmlns=\"\(host)\">" +
            "\(parameters)" +
            "</\(method)>" +
            "</soap:Body>" +
        "</soap:Envelope>"

        var request = URLRequest(url: URL(string: requestUrl)!)
        
        request.httpMethod = "POST"
        request.httpBody = bodyString.data(using: .utf8)
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("\(host)\(method)", forHTTPHeaderField: "SOAPAction")
        
        return request
    }
    
}
