//
//  ContentView.swift
//  GridSearch
//
//  Created by Sergey Antoniuk on 1/12/21.
//

import SwiftUI
import Kingfisher

struct RSS: Decodable {
    let feed:Feed
}
struct Feed: Decodable {
    let results: [Result]
}
struct Result: Decodable, Hashable {
    let copyright, name, artworkUrl100,releaseDate: String
}



class GridViewModel: ObservableObject {
    @Published var items = 0..<10
    @Published var results = [Result]()
@Published var searchText = ""
    @Published var isSeaching = false
    
    init() {
//        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
//            items = 0..<7
//        }
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/25/explicit.json") else {
            return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                print(rss)
                DispatchQueue.main.async {
                    self.results = rss.feed.results
                }
               
            } catch {
                print ("Failed to decode: \(error)")
            }
        }.resume()
        
    }
}

struct ContentView: View {
    @ObservedObject var vm = GridViewModel()
   // @State var searchText = ""
   // @StateObject var viewmodel = GridViewModel()
    var body: some View {
        NavigationView{
            VStack{
                
                TextField("Search", text: $vm.searchText)
                .padding()
                .background(Color(.systemGray4))
                .padding(.horizontal, 8)
                .cornerRadius(15)
                    .onTapGesture(perform: {
                        vm.isSeaching = true
                    })
                    .overlay(
                        HStack{
                            Spacer()
                            if vm.isSeaching{
                                Button(action: {
                                    vm.searchText = ""
                                    
                                    //switchoff keyboard
//                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .scaleEffect(1.5)
                                        .foregroundColor(.gray)
                                        
                                        
                                })
                            
                            }
                        }.padding()
                    )
                
                
            ScrollView{
                LazyVGrid(columns:
                            [GridItem(.flexible(minimum: 50, maximum: 200), spacing: 0, alignment: .top),
                             GridItem(.flexible(minimum: 50, maximum: 200),spacing: 0, alignment: .top),
                             GridItem(.flexible(minimum: 50, maximum: 200),alignment: .top)],  alignment: .leading, spacing: 8, content: {
                              
                                ForEach(vm.results.filter{ ($0.name.contains(vm.searchText) || vm.searchText.isEmpty) }
                                , id:\.self) { app in
                                    AppInfo(app: app)
                                }
                               
                                
                             })
            }
            .navigationTitle("Grid Search")
        }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}

struct AppInfo: View {
    var app: Result
    
    var body: some View {
        VStack(alignment: .leading){
            KFImage(URL(string: app.artworkUrl100))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(6)
            
            Text(app.name)
            Text(app.copyright)
                .font(.system(size: 13 , weight: .regular))
            Text("by Sergey")
                .font(.system(size: 25))                                    }
            .font(.system(size: 15))
            .foregroundColor(.white)
            .background(Color.gray)
            .cornerRadius(6)
            
            .padding(.horizontal, 8)
    }
}
