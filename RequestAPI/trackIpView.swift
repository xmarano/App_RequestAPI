//
//  trackIpView.swift
//  RequestAPI
//
//  Created by Léo Grégori on 28/06/2024.
//

import SwiftUI
import MapKit

struct Place: Identifiable {
    var id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
}

struct trackIpView: View {
    @State var ipNumber: String = ""
    @StateObject private var viewModel = IpTrackingFunc()
    
    var body: some View {
        VStack {
            
            @State var region = MKCoordinateRegion(
                center: .init(latitude: CLLocationDegrees(viewModel.ip_latitude), longitude: CLLocationDegrees(viewModel.ip_longitude)),
                span: .init(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
            
            let annotations = [Place(
                name: "IP's Place",
                coordinate: .init(
                    latitude: CLLocationDegrees(viewModel.ip_latitude),
                    longitude: CLLocationDegrees(viewModel.ip_longitude)),
                color: .black
            )]
            
            TextField("Enter your IP address (IPv6 or IPv4)", text: $ipNumber, onCommit: {
                viewModel.updateIP(ipNumber)
            })
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(.bar, in: RoundedRectangle(cornerRadius: 10))
            
            Text("Country: \(viewModel.ip_country)")
            Text("City: \(viewModel.ip_city)")
            Text("Postal Code: \(viewModel.ip_postal_code)")
            Text("Telecom operator: \(viewModel.ip_isp_name)")
            Text("Latitude: \(viewModel.ip_latitude)")
            Text("Longitude: \(viewModel.ip_longitude)")
            

            Map(coordinateRegion: $region, annotationItems: annotations) {
                MapMarker(coordinate: $0.coordinate, tint: $0.color)
            }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}

class IpTrackingFunc: ObservableObject {
    @Published var ipNumber: String = ""
    @Published var ip_city: String = ""
    @Published var ip_postal_code: String = ""
    @Published var ip_country: String = ""
    @Published var ip_isp_name: String = ""
    @Published var ip_latitude: Float = 0
    @Published var ip_longitude: Float = 0
    
    func updateIP(_ newIP: String) {
        self.ipNumber = newIP
        let url = "https://ipgeolocation.abstractapi.com/v1/?api_key=fe216bd7ccbf4ce8a83e44db246b5242&ip_address=\(ipNumber)"
        fetchIPDetails(from: url)
    }
    
    private func fetchIPDetails(from url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(IP_Response.self, from: data)
                DispatchQueue.main.async {
                    self.ip_city = result.city
                    self.ip_postal_code = result.postal_code
                    self.ip_country = result.country
                    self.ip_isp_name = result.connection.isp_name
                    self.ip_latitude = result.latitude
                    self.ip_longitude = result.longitude
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

struct IP_Response: Codable {
    let ip_address: String
    let city: String
    let city_geoname_id: Int
    let region: String
    let region_iso_code: String
    let region_geoname_id: Int
    let postal_code: String
    let country: String
    let country_code: String
    let country_geoname_id: Int
    let country_is_eu: Bool
    let continent: String
    let continent_code: String
    let continent_geoname_id: Int
    let longitude: Float
    let latitude: Float
    let security: IpSecurity
    let timezone: IpTimezone
    let flag: IpFlag
    let currency: IpCurrency
    let connection: IpConnection
}

struct IpSecurity: Codable {
    let is_vpn: Bool
}

struct IpTimezone: Codable {
    let name: String
    let abbreviation: String
    let gmt_offset: Int
    let current_time: String
    let is_dst: Bool
}

struct IpFlag: Codable {
    let emoji: String
    let unicode: String
    let png: String
    let svg: String
}

struct IpCurrency: Codable {
    let currency_name: String
    let currency_code: String
}

struct IpConnection: Codable {
    let autonomous_system_number: UInt32
    let autonomous_system_organization: String
    let connection_type: String
    let isp_name: String
    let organization_name: String
}

#Preview {
    ContentView()
}

// API JSON ABSTRACTAPI
/*
 {
     "ip_address": "166.171.248.255",
     "city": "San Jose",
     "city_geoname_id": 5392171,
     "region": "California",
     "region_iso_code": "CA",
     "region_geoname_id": 5332921,
     "postal_code": "95141",
     "country": "United States",
     "country_code": "US",
     "country_geoname_id": 6252001,
     "country_is_eu": false,
     "continent": "North America",
     "continent_code": "NA",
     "continent_geoname_id": 6255149,
     "longitude": -121.7714,
     "latitude": 37.1835,
     "security": {
         "is_vpn": false
     },
     "timezone": {
         "name": "America/Los_Angeles",
         "abbreviation": "PDT",
         "gmt_offset": -7,
         "current_time": "06:37:41",
         "is_dst": true
     },
     "flag": {
         "emoji": "🇺🇸",
         "unicode": "U+1F1FA U+1F1F8",
         "png": "https://static.abstractapi.com/country-flags/US_flag.png",
         "svg": "https://static.abstractapi.com/country-flags/US_flag.svg"
     },
     "currency": {
         "currency_name": "USD",
         "currency_code": "USD"
     },
     "connection": {
         "autonomous_system_number": 20057,
         "autonomous_system_organization": "ATT-MOBILITY-LLC-AS20057",
         "connection_type": "Cellular",
         "isp_name": "AT&T Mobility LLC",
         "organization_name": "Service Provider Corporation"
     }
 }

*/
