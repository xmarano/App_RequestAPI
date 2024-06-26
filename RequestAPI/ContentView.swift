//
//  ContentView.swift
//  RequestAPI
//
//  Created by Léo Grégori on 25/06/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = SunriseSunset()

    let locationManager = CLLocationManager()

    @State var region = MKCoordinateRegion(
        center: .init(latitude: 0,longitude: 0),
        span: .init(latitudeDelta: 10, longitudeDelta: 10)
    )

    var body: some View {
        VStack {
            Text("City: \(viewModel.city)")
                .font(.largeTitle)
                .padding(.bottom)
            Text("Sunrise: \(viewModel.sunrise)")
            Text("Sunset: \(viewModel.sunset)")
            Text("Day length: \(viewModel.day_length)")
            Text("Latitude: \(viewModel.map_latitude)")
            Text("Longitude: \(viewModel.map_longitude)")
            
            Button("Fetch Data") { viewModel.fetchData() }
                .padding()
            
            Text("Status: \(viewModel.status)")
                .padding(.bottom, 16)

            Map(
              coordinateRegion: $region,
              showsUserLocation: true,
              userTrackingMode: .constant(.follow)
            )
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                //.edgesIgnoringSafeArea(.all)
        }
        .padding(.top, 100)
        .padding(.horizontal, 16)
        .onAppear { viewModel.fetchData() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
