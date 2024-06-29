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
    @State private var showingIP = false
    
    let locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            @State var region = MKCoordinateRegion(
                center: .init(latitude: viewModel.map_latitude, longitude: viewModel.map_longitude),
                span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
            
            Text("City: \(viewModel.city)")
                .font(.largeTitle)
                .padding(.bottom)
            
            Text("Sunrise: \(viewModel.sunrise)")
            Text("Sunset: \(viewModel.sunset)")
            Text("Day length: \(viewModel.day_length)")
            Text("Latitude: \(viewModel.map_latitude)")
            Text("Longitude: \(viewModel.map_longitude)")
            
            Button("Update Data") { viewModel.fetchData() }
                .padding()
            
            Button("Status: \(viewModel.status)") { showingIP = true }
                .padding(.bottom, 16)
            
            Map(
              coordinateRegion: $region,
              showsUserLocation: true
            )
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                //.edgesIgnoringSafeArea(.all)
        }
        .padding(.top, 100)
        .padding(.horizontal, 30)
        .onAppear { viewModel.fetchData() }
        
        .sheet(isPresented: $showingIP, content: {
            trackIpView()
                .presentationDetents([.height(.infinity)])
                .presentationCornerRadius(25)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
