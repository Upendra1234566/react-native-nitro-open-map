
// import UIKit
// import MapLibre
// import NitroModules

// // Delegate ko alag nikal diya taaki multiple inheritance (NSObject) ki error na aaye
// class MapLibreDelegateHelper: NSObject, MLNMapViewDelegate {
//     weak var parent: HybridNitroOpenMap?
    
//     init(parent: HybridNitroOpenMap) {
//         self.parent = parent
//     }
    
//     func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
//         parent?.onMapLoaded(style: style)
//     }
// }

// @objcMembers
// public class HybridNitroOpenMap: HybridNitroOpenMapSpec {

//   private var wrapperView: UIView
//   private var mapView: MLNMapView
//   private var mapLibreMap: MLNStyle? = nil
//   private var isMapReady = false
//   private var draggedMarkerId: String? = nil
//   private var mapDelegateHelper: MapLibreDelegateHelper!

//   // MARK: - Public Properties required by Nitro Spec
//   public var view: UIView {
//     return wrapperView
//   }

//   private var _color: String = "#FFFFFF"
//   public var color: String {
//     get { return _color }
//     set {
//       _color = newValue
//       DispatchQueue.main.async { self.wrapperView.backgroundColor = self.parseColor(newValue) }
//     }
//   }
  
//   private var _latitude: Double? = nil
//   public var latitude: Double? {
//     get { return _latitude }
//     set { _latitude = newValue; updateCamera() }
//   }

//   private var _longitude: Double? = nil
//   public var longitude: Double? {
//     get { return _longitude }
//     set { _longitude = newValue; updateCamera() }
//   }

//   private var _zoom: Double? = 12.0
//   public var zoom: Double? {
//     get { return _zoom }
//     set { _zoom = newValue; updateCamera() }
//   }

//   private var _bearing: Double? = 0.0
//   public var bearing: Double? {
//     get { return _bearing }
//     set { _bearing = newValue; updateCamera() }
//   }

//   private var _tilt: Double? = 0.0
//   public var tilt: Double? {
//     get { return _tilt }
//     set { _tilt = newValue; updateCamera() }
//   }
  
//   private var _mapStyle: String? = "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
//   public var mapStyle: String? {
//     get { return _mapStyle }
//     set {
//       _mapStyle = newValue
//       DispatchQueue.main.async {
//         if let styleUrl = newValue, let url = URL(string: styleUrl) {
//           self.mapView.styleURL = url
//         }
//       }
//     }
//   }

//   private var _markers: [Marker]? = []
//   public var markers: [Marker]? {
//     get { return _markers }
//     set { _markers = newValue; DispatchQueue.main.async { self.updateMarkers() } }
//   }

//   private var _showUserLocation: Bool? = false
//   public var showUserLocation: Bool? {
//     get { return _showUserLocation }
//     set { _showUserLocation = newValue; DispatchQueue.main.async { self.updateUserLocationState() } }
//   }

//   private var _vehicleMarker: Marker? = nil
//   public var vehicleMarker: Marker? {
//     get { return _vehicleMarker }
//     set { _vehicleMarker = newValue; DispatchQueue.main.async { self.updateVehicleMarker() } }
//   }

//   private var _fitBoundsCoords: [LatLng]? = nil
//   public var fitBoundsCoords: [LatLng]? {
//     get { return _fitBoundsCoords }
//     set { _fitBoundsCoords = newValue }
//   }

//   private var _polylines: [Polyline]? = []
//   public var polylines: [Polyline]? {
//     get { return _polylines }
//     set { _polylines = newValue; DispatchQueue.main.async { self.updatePolylines() } }
//   }

//   private var _polygons: [Polygon]? = []
//   public var polygons: [Polygon]? {
//     get { return _polygons }
//     set { _polygons = newValue; DispatchQueue.main.async { self.updatePolygons() } }
//   }

//   public var onMarkerPress: ((String) -> Void)? = nil
//   public var onMarkerDragEnd: ((String, Double, Double) -> Void)? = nil

//   // MARK: - Initialization
//   public override init() {
//     wrapperView = UIView()
//     mapView = MLNMapView(frame: .zero, styleURL: URL(string: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"))
//     mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//     wrapperView.addSubview(mapView)
    
//     super.init()
    
//     // Setting up the delegate via Helper
//     mapDelegateHelper = MapLibreDelegateHelper(parent: self)
//     mapView.delegate = mapDelegateHelper
//     mapView.showsUserLocation = false

//     let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
//     mapView.addGestureRecognizer(tapGesture)

//     let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMapLongPress(_:)))
//     mapView.addGestureRecognizer(longPressGesture)
//   }

//   // MARK: - Map Loaded & Helpers
//   func onMapLoaded(style: MLNStyle) {
//     mapLibreMap = style
//     isMapReady = true

//     // Set Default Image for fallback
//     style.setImage(createDefaultMarkerImage(), forName: "default_marker_icon")

//     setupLayersAndSources(style: style)
    
//     DispatchQueue.main.async {
//       self.updateCamera()
//       self.updateMarkers()
//       self.updateVehicleMarker()
//       self.updatePolylines()
//       self.updatePolygons()
//       self.updateUserLocationState()
//     }
//   }

//   // Bada aur prominent fallback image taaki 0.25/0.3 scale hone par gayab na ho
//   private func createDefaultMarkerImage() -> UIImage {
//     let size = CGSize(width: 250, height: 250)
//     UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//     guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
    
//     // Outer White Border (taaki map ke background me mix na ho)
//     context.setFillColor(UIColor.white.cgColor)
//     context.fillEllipse(in: CGRect(x: 10, y: 10, width: 230, height: 230))
    
//     // Inner Bright Red Circle
//     context.setFillColor(UIColor.red.cgColor)
//     context.fillEllipse(in: CGRect(x: 35, y: 35, width: 180, height: 180))
    
//     let image = UIGraphicsGetImageFromCurrentImageContext()
//     UIGraphicsEndImageContext()
    
//     return image ?? UIImage()
//   }

//   private func setupLayersAndSources(style: MLNStyle) {
//     let polygonSource = MLNShapeSource(identifier: "polygon-source", shape: nil, options: nil)
//     style.addSource(polygonSource)
//     let polygonLayer = MLNFillStyleLayer(identifier: "polygon-layer", source: polygonSource)
//     polygonLayer.fillColor = NSExpression(forConstantValue: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2))
//     polygonLayer.fillOutlineColor = NSExpression(forConstantValue: UIColor.red)
//     style.addLayer(polygonLayer)

//     let polylineSource = MLNShapeSource(identifier: "polyline-source", shape: nil, options: nil)
//     style.addSource(polylineSource)
//     let polylineLayer = MLNLineStyleLayer(identifier: "polyline-layer", source: polylineSource)
//     polylineLayer.lineColor = NSExpression(forConstantValue: UIColor.red)
//     polylineLayer.lineWidth = NSExpression(forConstantValue: 5.0)
//     style.addLayer(polylineLayer)

//     let markerOptions: [MLNShapeSourceOption: Any] = [
//       .clustered: true,
//       .clusterRadius: 50,
//       .maximumZoomLevelForClustering: 14
//     ]
//     let markerSource = MLNShapeSource(identifier: "marker-source", shape: nil, options: markerOptions)
//     style.addSource(markerSource)

//     let clusterCircleLayer = MLNCircleStyleLayer(identifier: "cluster-circle-layer", source: markerSource)
//     clusterCircleLayer.circleColor = NSExpression(forConstantValue: UIColor(red: 1.0, green: 0.34, blue: 0.13, alpha: 1.0))
//     clusterCircleLayer.circleRadius = NSExpression(forConstantValue: 18.0)
//     clusterCircleLayer.circleStrokeWidth = NSExpression(forConstantValue: 2.0)
//     clusterCircleLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
//     clusterCircleLayer.predicate = NSPredicate(format: "cluster == YES")
//     style.addLayer(clusterCircleLayer)

//     let clusterCountLayer = MLNSymbolStyleLayer(identifier: "cluster-count-layer", source: markerSource)
//     clusterCountLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
//     clusterCountLayer.textFontSize = NSExpression(forConstantValue: 12.0)
//     clusterCountLayer.textColor = NSExpression(forConstantValue: UIColor.white)
//     clusterCountLayer.textAnchor = NSExpression(forConstantValue: NSValue(mlnTextAnchor: .center))
//     clusterCountLayer.predicate = NSPredicate(format: "cluster == YES")
//     style.addLayer(clusterCountLayer)

//     let markerLayer = MLNSymbolStyleLayer(identifier: "marker-layer", source: markerSource)
//     markerLayer.text = NSExpression(forKeyPath: "title")
//     markerLayer.textFontSize = NSExpression(forConstantValue: 14.0)
//     markerLayer.textColor = NSExpression(forConstantValue: UIColor.black)
//     markerLayer.textOffset = NSExpression(forConstantValue: NSValue(cgVector: CGVector(dx: 0, dy: 1.8)))
//     markerLayer.textAnchor = NSExpression(forConstantValue: NSValue(mlnTextAnchor: .top))
//     markerLayer.iconImageName = NSExpression(forKeyPath: "iconImage")
//     markerLayer.iconScale = NSExpression(forConstantValue: 0.25)
//     markerLayer.iconRotation = NSExpression(forKeyPath: "rotation")
//     markerLayer.iconRotationAlignment = NSExpression(forConstantValue: NSValue(mlnIconRotationAlignment: .map))
//     markerLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
//     markerLayer.textAllowsOverlap = NSExpression(forConstantValue: false)
    
//     // Image delay ho toh bhi Text show ho
//     markerLayer.iconOptional = NSExpression(forConstantValue: true)
//     markerLayer.textOptional = NSExpression(forConstantValue: true)
    
//     markerLayer.predicate = NSPredicate(format: "cluster != YES")
//     style.addLayer(markerLayer)

//     let vehicleSource = MLNShapeSource(identifier: "vehicle-source", shape: nil, options: nil)
//     style.addSource(vehicleSource)
//     let vehicleLayer = MLNSymbolStyleLayer(identifier: "vehicle-layer", source: vehicleSource)
//     vehicleLayer.text = NSExpression(forKeyPath: "title")
//     vehicleLayer.textFontSize = NSExpression(forConstantValue: 14.0)
//     vehicleLayer.textColor = NSExpression(forConstantValue: UIColor.blue)
//     vehicleLayer.textOffset = NSExpression(forConstantValue: NSValue(cgVector: CGVector(dx: 0, dy: 1.8)))
//     vehicleLayer.textAnchor = NSExpression(forConstantValue: NSValue(mlnTextAnchor: .top))
//     vehicleLayer.iconImageName = NSExpression(forKeyPath: "iconImage")
//     vehicleLayer.iconScale = NSExpression(forConstantValue: 0.3)
//     vehicleLayer.iconRotation = NSExpression(forKeyPath: "rotation")
//     vehicleLayer.iconRotationAlignment = NSExpression(forConstantValue: NSValue(mlnIconRotationAlignment: .map))
//     vehicleLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
    
//     vehicleLayer.iconOptional = NSExpression(forConstantValue: true)
//     vehicleLayer.textOptional = NSExpression(forConstantValue: true)
    
//     style.addLayer(vehicleLayer)
//   }

//   @objc private func handleMapTap(_ sender: UITapGestureRecognizer) {
//     let point = sender.location(in: mapView)
//     let rect = CGRect(x: point.x - 25, y: point.y - 25, width: 50, height: 50)
//     let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: Set(["marker-layer", "vehicle-layer", "cluster-circle-layer"]))
    
//     if let feature = features.first, let markerId = feature.attribute(forKey: "id") as? String, !markerId.isEmpty {
//       onMarkerPress?(markerId)
//     }
//   }

//   @objc private func handleMapLongPress(_ sender: UILongPressGestureRecognizer) {
//     if sender.state == .began {
//       let point = sender.location(in: mapView)
//       let rect = CGRect(x: point.x - 30, y: point.y - 30, width: 60, height: 60)
//       let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: Set(["marker-layer"]))
      
//       if let feature = features.first,
//          let markerId = feature.attribute(forKey: "id") as? String,
//          let isDraggable = feature.attribute(forKey: "draggable") as? Bool,
//          isDraggable {
//         draggedMarkerId = markerId
//       }
//     } else if sender.state == .ended {
//       if let currentId = draggedMarkerId {
//         let centerCoord = mapView.centerCoordinate
//         onMarkerDragEnd?(currentId, centerCoord.latitude, centerCoord.longitude)
//         draggedMarkerId = nil
//       }
//     }
//   }

//   private func updateCamera() {
//     guard let lat = _latitude, let lng = _longitude, isMapReady else { return }
//     DispatchQueue.main.async {
//       self.mapView.setCenter(
//         CLLocationCoordinate2D(latitude: lat, longitude: lng),
//         zoomLevel: self._zoom ?? 12.0,
//         direction: self._bearing ?? 0.0,
//         animated: false
//       )
      
//       let camera = self.mapView.camera
//       camera.pitch = CGFloat(self._tilt ?? 0.0)
//       self.mapView.setCamera(camera, animated: false)
//     }
//   }

//   public func animateCamera(latitude: Double, longitude: Double, zoom: Double?, durationMs: Double?) {
//     guard isMapReady else { return }
//     let targetZoom = zoom ?? _zoom ?? 12.0
//     let duration = durationMs != nil ? durationMs! / 1000.0 : 1.0
    
//     DispatchQueue.main.async {
//       let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//       self.mapView.setCenter(center, zoomLevel: targetZoom, direction: self._bearing ?? 0.0, animated: false)
//       let camera = self.mapView.camera
//       camera.pitch = CGFloat(self._tilt ?? 0.0)
//       self.mapView.setCamera(camera, withDuration: TimeInterval(duration), animationTimingFunction: nil)
//     }
//   }

//   public func fitBounds(coordinates: [LatLng], padding: Double?) {
//     guard isMapReady, !coordinates.isEmpty else { return }
//     DispatchQueue.main.async {
//       let coords = coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
//       var bounds = MLNCoordinateBounds(sw: coords[0], ne: coords[0])
//       for coord in coords {
//         bounds.sw.latitude = min(bounds.sw.latitude, coord.latitude)
//         bounds.sw.longitude = min(bounds.sw.longitude, coord.longitude)
//         bounds.ne.latitude = max(bounds.ne.latitude, coord.latitude)
//         bounds.ne.longitude = max(bounds.ne.longitude, coord.longitude)
//       }
//       let pad = UIEdgeInsets(top: CGFloat(padding ?? 100), left: CGFloat(padding ?? 100), bottom: CGFloat(padding ?? 100), right: CGFloat(padding ?? 100))
//       self.mapView.setVisibleCoordinateBounds(bounds, edgePadding: pad, animated: true)
//     }
//   }

//   public func downloadOfflineRegion(swLat: Double, swLng: Double, neLat: Double, neLng: Double, minZoom: Double, maxZoom: Double, regionName: String) {
//     DispatchQueue.main.async {
//       guard let styleURL = self.mapView.styleURL else { return }
//       let bounds = MLNCoordinateBounds(sw: CLLocationCoordinate2D(latitude: swLat, longitude: swLng), ne: CLLocationCoordinate2D(latitude: neLat, longitude: neLng))
      
//       let region = MLNTilePyramidOfflineRegion(styleURL: styleURL, bounds: bounds, fromZoomLevel: minZoom, toZoomLevel: maxZoom)
//       let contextData = regionName.data(using: .utf8)
      
//       MLNOfflineStorage.shared.addPack(for: region, withContext: contextData ?? Data()) { (pack, error) in
//         pack?.resume()
//       }
//     }
//   }

//   private func updateMarkers() {
//     guard isMapReady else { return }
//     let markersArray = _markers ?? []
    
//     for marker in markersArray {
//       if let img = marker.iconImage, img.hasPrefix("http://") || img.hasPrefix("https://") {
//         downloadAndAddImage(urlStr: img)
//       }
//     }
    
//     guard let style = mapView.style, let source = style.source(withIdentifier: "marker-source") as? MLNShapeSource else { return }
//     var features: [MLNPointFeature] = []
    
//     for marker in markersArray {
//       let feature = MLNPointFeature()
//       feature.coordinate = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
//       feature.attributes = [
//         "id": marker.id ?? "",
//         "title": marker.title ?? "",
//         "snippet": marker.snippet ?? "",
//         "rating": marker.rating ?? "",
//         "eta": marker.eta ?? "",
//         "color": marker.color ?? "#FF0000",
//         "iconImage": marker.iconImage ?? "default_marker_icon",
//         "rotation": marker.rotation ?? 0.0,
//         "draggable": marker.draggable ?? false
//       ]
//       features.append(feature)
//     }
//     source.shape = MLNShapeCollection(shapes: features)
//   }

//   private func updateVehicleMarker() {
//     guard let vehicle = _vehicleMarker, isMapReady else { return }
    
//     if let img = vehicle.iconImage, img.hasPrefix("http://") || img.hasPrefix("https://") {
//       downloadAndAddImage(urlStr: img)
//     }
    
//     guard let style = mapView.style, let source = style.source(withIdentifier: "vehicle-source") as? MLNShapeSource else { return }
//     let feature = MLNPointFeature()
//     feature.coordinate = CLLocationCoordinate2D(latitude: vehicle.latitude, longitude: vehicle.longitude)
//     feature.attributes = [
//       "id": vehicle.id ?? "live_vehicle",
//       "title": vehicle.title ?? "",
//       "iconImage": vehicle.iconImage ?? "default_marker_icon",
//       "rotation": vehicle.rotation ?? 0.0
//     ]
//     source.shape = feature
//   }

//   private func updatePolylines() {
//     guard let style = mapView.style, let source = style.source(withIdentifier: "polyline-source") as? MLNShapeSource, isMapReady else { return }
//     var mPolylines: [MLNPolyline] = []
//     let lines = _polylines ?? []
//     for poly in lines {
//       var coords = poly.coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
//       let polyline = MLNPolyline(coordinates: &coords, count: UInt(coords.count))
//       mPolylines.append(polyline)
//     }
//     source.shape = MLNShapeCollection(shapes: mPolylines)
    
//     if let firstPoly = lines.first, let layer = style.layer(withIdentifier: "polyline-layer") as? MLNLineStyleLayer {
//       if let colorStr = firstPoly.color, !colorStr.isEmpty {
//         layer.lineColor = NSExpression(forConstantValue: parseColor(colorStr))
//       }
//       if let width = firstPoly.width {
//         layer.lineWidth = NSExpression(forConstantValue: CGFloat(width))
//       }
//     }
//   }

//   private func updatePolygons() {
//     guard let style = mapView.style, let source = style.source(withIdentifier: "polygon-source") as? MLNShapeSource, isMapReady else { return }
//     var mPolygons: [MLNPolygon] = []
//     let polys = _polygons ?? []
//     for poly in polys {
//       var coords = poly.coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
//       let polygon = MLNPolygon(coordinates: &coords, count: UInt(coords.count))
//       mPolygons.append(polygon)
//     }
//     source.shape = MLNShapeCollection(shapes: mPolygons)
    
//     if let firstPoly = polys.first, let layer = style.layer(withIdentifier: "polygon-layer") as? MLNFillStyleLayer {
//       if let fillColor = firstPoly.fillColor, !fillColor.isEmpty {
//         layer.fillColor = NSExpression(forConstantValue: parseColor(fillColor))
//       }
//       if let strokeColor = firstPoly.strokeColor, !strokeColor.isEmpty {
//         layer.fillOutlineColor = NSExpression(forConstantValue: parseColor(strokeColor))
//       }
//     }
//   }

//   private func updateUserLocationState() {
//     mapView.showsUserLocation = _showUserLocation ?? false
//   }

//   // Safe Image Downloading Taaki Main Thread Par properly attach ho sake
//   private func downloadAndAddImage(urlStr: String) {
//     guard let style = mapView.style, style.image(forName: urlStr) == nil else { return }
    
//     DispatchQueue.global(qos: .background).async {
//       guard let url = URL(string: urlStr), 
//             let data = try? Data(contentsOf: url), 
//             let downloadedImage = UIImage(data: data) else { return }
      
//       DispatchQueue.main.async {
//         if let currentStyle = self.mapView.style, currentStyle.image(forName: urlStr) == nil {
//           currentStyle.setImage(downloadedImage.withRenderingMode(.alwaysOriginal), forName: urlStr)
          
//           self.updateMarkers()
//           self.updateVehicleMarker()
//         }
//       }
//     }
//   }

//   // MARK: - Powerful Color Parser
//   public func parseColor(_ colorStr: String) -> UIColor {
//     let formattedStr = colorStr.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    
//     if formattedStr.hasPrefix("rgba") || formattedStr.hasPrefix("rgb") {
//         let characterSet = CharacterSet(charactersIn: "0123456789.")
//         let numbers = formattedStr.components(separatedBy: characterSet.inverted).filter { !$0.isEmpty }
        
//         if numbers.count >= 3 {
//             let r = CGFloat(Double(numbers[0]) ?? 0) / 255.0
//             let g = CGFloat(Double(numbers[1]) ?? 0) / 255.0
//             let b = CGFloat(Double(numbers[2]) ?? 0) / 255.0
//             let a = numbers.count >= 4 ? CGFloat(Double(numbers[3]) ?? 1.0) : 1.0
//             return UIColor(red: r, green: g, blue: b, alpha: a)
//         }
//     }
    
//     var hex = formattedStr
//     if hex.hasPrefix("#") {
//         hex.removeFirst()
//     }
    
//     var rgbValue: UInt64 = 0
//     Scanner(string: hex).scanHexInt64(&rgbValue)
    
//     if hex.count == 8 {
//         return UIColor(
//             red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
//             green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
//             blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
//             alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
//         )
//     } else if hex.count == 6 {
//         return UIColor(
//             red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//             green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//             blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//             alpha: 1.0
//         )
//     }
    
//     return UIColor.gray
//   }
// } 

import UIKit
import MapLibre
import NitroModules

// Delegate ko alag nikal diya taaki multiple inheritance (NSObject) ki error na aaye
class MapLibreDelegateHelper: NSObject, MLNMapViewDelegate {
    weak var parent: HybridNitroOpenMap?

    init(parent: HybridNitroOpenMap) {
        self.parent = parent
    }

    func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        parent?.onMapLoaded(style: style)
    }
}

@objcMembers
public class HybridNitroOpenMap: HybridNitroOpenMapSpec {

  private var wrapperView: UIView
  private var mapView: MLNMapView
  private var mapLibreMap: MLNStyle? = nil
  private var mapLoaded = false          // renamed from isMapReady (bool) to avoid clash with isMapReady() func
  private var draggedMarkerId: String? = nil
  private var mapDelegateHelper: MapLibreDelegateHelper!

  // MARK: - Public Properties required by Nitro Spec
  public var view: UIView {
    return wrapperView
  }

  private var _color: String = "#FFFFFF"
  public var color: String {
    get { return _color }
    set {
      _color = newValue
      DispatchQueue.main.async { self.wrapperView.backgroundColor = self.parseColor(newValue) }
    }
  }

  private var _latitude: Double? = nil
  public var latitude: Double? {
    get { return _latitude }
    set { _latitude = newValue; updateCamera() }
  }

  private var _longitude: Double? = nil
  public var longitude: Double? {
    get { return _longitude }
    set { _longitude = newValue; updateCamera() }
  }

  private var _zoom: Double? = 12.0
  public var zoom: Double? {
    get { return _zoom }
    set { _zoom = newValue; updateCamera() }
  }

  private var _bearing: Double? = 0.0
  public var bearing: Double? {
    get { return _bearing }
    set { _bearing = newValue; updateCamera() }
  }

  private var _tilt: Double? = 0.0
  public var tilt: Double? {
    get { return _tilt }
    set { _tilt = newValue; updateCamera() }
  }

  private var _mapStyle: String? = "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
  public var mapStyle: String? {
    get { return _mapStyle }
    set {
      _mapStyle = newValue
      DispatchQueue.main.async {
        if let styleUrl = newValue, let url = URL(string: styleUrl) {
          self.mapView.styleURL = url
        }
      }
    }
  }

  private var _markers: [Marker]? = []
  public var markers: [Marker]? {
    get { return _markers }
    set { _markers = newValue; DispatchQueue.main.async { self.updateMarkers() } }
  }

  private var _showUserLocation: Bool? = false
  public var showUserLocation: Bool? {
    get { return _showUserLocation }
    set { _showUserLocation = newValue; DispatchQueue.main.async { self.updateUserLocationState() } }
  }

  private var _vehicleMarker: Marker? = nil
  public var vehicleMarker: Marker? {
    get { return _vehicleMarker }
    set { _vehicleMarker = newValue; DispatchQueue.main.async { self.updateVehicleMarker() } }
  }

  private var _fitBoundsCoords: [LatLng]? = nil
  public var fitBoundsCoords: [LatLng]? {
    get { return _fitBoundsCoords }
    set {
      _fitBoundsCoords = newValue
      if let coords = newValue, !coords.isEmpty {
        fitBounds(coordinates: coords, padding: 100.0)
      }
    }
  }

  private var _polylines: [Polyline]? = []
  public var polylines: [Polyline]? {
    get { return _polylines }
    set { _polylines = newValue; DispatchQueue.main.async { self.updatePolylines() } }
  }

  private var _polygons: [Polygon]? = []
  public var polygons: [Polygon]? {
    get { return _polygons }
    set { _polygons = newValue; DispatchQueue.main.async { self.updatePolygons() } }
  }

  // MARK: - routeRequest (was missing)
  private var _routeRequest: RouteRequest? = nil
  public var routeRequest: RouteRequest? {
    get { return _routeRequest }
    set {
      _routeRequest = newValue
      if let req = newValue {
        fetchAndDrawRouteNative(
          originLat: req.originLat,
          originLng: req.originLng,
          destLat: req.destLat,
          destLng: req.destLng
        )
      }
    }
  }

  public var onMarkerPress: ((String) -> Void)? = nil
  public var onMarkerDragEnd: ((String, Double, Double) -> Void)? = nil

  // MARK: - onMapReady (was missing)
  private var _onMapReady: (() -> Void)? = nil
  public var onMapReady: (() -> Void)? {
    get { return _onMapReady }
    set {
      _onMapReady = newValue
      if mapLoaded {
        DispatchQueue.main.async { newValue?() }
      }
    }
  }

  // MARK: - Initialization
  public override init() {
    wrapperView = UIView()
    mapView = MLNMapView(frame: .zero, styleURL: URL(string: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"))
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    wrapperView.addSubview(mapView)

    super.init()

    // Setting up the delegate via Helper
    mapDelegateHelper = MapLibreDelegateHelper(parent: self)
    mapView.delegate = mapDelegateHelper
    mapView.showsUserLocation = false

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
    mapView.addGestureRecognizer(tapGesture)

    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMapLongPress(_:)))
    mapView.addGestureRecognizer(longPressGesture)
  }

  // MARK: - isMapReady() function required by spec (returns a Promise<Bool>)
  public func isMapReady() -> Promise<Bool> {
    return Promise.resolved(withResult: mapLoaded)
  }

  // MARK: - Map Loaded & Helpers
  func onMapLoaded(style: MLNStyle) {
    mapLibreMap = style
    mapLoaded = true

    // Set Default Image for fallback
    style.setImage(createDefaultMarkerImage(), forName: "default_marker_icon")

    setupLayersAndSources(style: style)

    DispatchQueue.main.async {
      self.updateCamera()
      self.updateMarkers()
      self.updateVehicleMarker()
      self.updatePolylines()
      self.updatePolygons()
      self.updateUserLocationState()
      self._onMapReady?()
    }
  }

  // Bada aur prominent fallback image taaki 0.25/0.3 scale hone par gayab na ho
  private func createDefaultMarkerImage() -> UIImage {
    let size = CGSize(width: 250, height: 250)
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

    // Outer White Border (taaki map ke background me mix na ho)
    context.setFillColor(UIColor.white.cgColor)
    context.fillEllipse(in: CGRect(x: 10, y: 10, width: 230, height: 230))

    // Inner Bright Red Circle
    context.setFillColor(UIColor.red.cgColor)
    context.fillEllipse(in: CGRect(x: 35, y: 35, width: 180, height: 180))

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image ?? UIImage()
  }

  private func setupLayersAndSources(style: MLNStyle) {
    let polygonSource = MLNShapeSource(identifier: "polygon-source", shape: nil, options: nil)
    style.addSource(polygonSource)
    let polygonLayer = MLNFillStyleLayer(identifier: "polygon-layer", source: polygonSource)
    polygonLayer.fillColor = NSExpression(forConstantValue: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2))
    polygonLayer.fillOutlineColor = NSExpression(forConstantValue: UIColor.red)
    style.addLayer(polygonLayer)

    let polylineSource = MLNShapeSource(identifier: "polyline-source", shape: nil, options: nil)
    style.addSource(polylineSource)
    let polylineLayer = MLNLineStyleLayer(identifier: "polyline-layer", source: polylineSource)
    polylineLayer.lineColor = NSExpression(forConstantValue: UIColor.red)
    polylineLayer.lineWidth = NSExpression(forConstantValue: 5.0)
    style.addLayer(polylineLayer)

    let markerOptions: [MLNShapeSourceOption: Any] = [
      .clustered: true,
      .clusterRadius: 50,
      .maximumZoomLevelForClustering: 14
    ]
    let markerSource = MLNShapeSource(identifier: "marker-source", shape: nil, options: markerOptions)
    style.addSource(markerSource)

    let clusterCircleLayer = MLNCircleStyleLayer(identifier: "cluster-circle-layer", source: markerSource)
    clusterCircleLayer.circleColor = NSExpression(forConstantValue: UIColor(red: 1.0, green: 0.34, blue: 0.13, alpha: 1.0))
    clusterCircleLayer.circleRadius = NSExpression(forConstantValue: 18.0)
    clusterCircleLayer.circleStrokeWidth = NSExpression(forConstantValue: 2.0)
    clusterCircleLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
    clusterCircleLayer.predicate = NSPredicate(format: "cluster == YES")
    style.addLayer(clusterCircleLayer)

    let clusterCountLayer = MLNSymbolStyleLayer(identifier: "cluster-count-layer", source: markerSource)
    clusterCountLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
    clusterCountLayer.textFontSize = NSExpression(forConstantValue: 12.0)
    clusterCountLayer.textColor = NSExpression(forConstantValue: UIColor.white)
    clusterCountLayer.textAnchor = NSExpression(forConstantValue: NSValue(mlnTextAnchor: .center))
    clusterCountLayer.predicate = NSPredicate(format: "cluster == YES")
    style.addLayer(clusterCountLayer)

    let markerLayer = MLNSymbolStyleLayer(identifier: "marker-layer", source: markerSource)
    markerLayer.text = NSExpression(forKeyPath: "title")
    markerLayer.textFontSize = NSExpression(forConstantValue: 14.0)
    markerLayer.textColor = NSExpression(forConstantValue: UIColor.black)
    markerLayer.textOffset = NSExpression(forConstantValue: NSValue(cgVector: CGVector(dx: 0, dy: 1.8)))
    markerLayer.textAnchor = NSExpression(forConstantValue: NSValue(mlnTextAnchor: .top))
    markerLayer.iconImageName = NSExpression(forKeyPath: "iconImage")
    markerLayer.iconScale = NSExpression(forConstantValue: 0.25)
    markerLayer.iconRotation = NSExpression(forKeyPath: "rotation")
    markerLayer.iconRotationAlignment = NSExpression(forConstantValue: NSValue(mlnIconRotationAlignment: .map))
    markerLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
    markerLayer.textAllowsOverlap = NSExpression(forConstantValue: false)

    // Image delay ho toh bhi Text show ho
    markerLayer.iconOptional = NSExpression(forConstantValue: true)
    markerLayer.textOptional = NSExpression(forConstantValue: true)

    markerLayer.predicate = NSPredicate(format: "cluster != YES")
    style.addLayer(markerLayer)

    let vehicleSource = MLNShapeSource(identifier: "vehicle-source", shape: nil, options: nil)
    style.addSource(vehicleSource)
    let vehicleLayer = MLNSymbolStyleLayer(identifier: "vehicle-layer", source: vehicleSource)
    vehicleLayer.text = NSExpression(forKeyPath: "title")
    vehicleLayer.textFontSize = NSExpression(forConstantValue: 14.0)
    vehicleLayer.textColor = NSExpression(forConstantValue: UIColor.blue)
    vehicleLayer.textOffset = NSExpression(forConstantValue: NSValue(cgVector: CGVector(dx: 0, dy: 1.8)))
    vehicleLayer.textAnchor = NSExpression(forConstantValue: NSValue(mlnTextAnchor: .top))
    vehicleLayer.iconImageName = NSExpression(forKeyPath: "iconImage")
    vehicleLayer.iconScale = NSExpression(forConstantValue: 0.3)
    vehicleLayer.iconRotation = NSExpression(forKeyPath: "rotation")
    vehicleLayer.iconRotationAlignment = NSExpression(forConstantValue: NSValue(mlnIconRotationAlignment: .map))
    vehicleLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)

    vehicleLayer.iconOptional = NSExpression(forConstantValue: true)
    vehicleLayer.textOptional = NSExpression(forConstantValue: true)

    style.addLayer(vehicleLayer)
  }

  @objc private func handleMapTap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: mapView)
    let rect = CGRect(x: point.x - 25, y: point.y - 25, width: 50, height: 50)
    let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: Set(["marker-layer", "vehicle-layer", "cluster-circle-layer"]))

    if let feature = features.first, let markerId = feature.attribute(forKey: "id") as? String, !markerId.isEmpty {
      onMarkerPress?(markerId)
    }
  }

  @objc private func handleMapLongPress(_ sender: UILongPressGestureRecognizer) {
    if sender.state == .began {
      let point = sender.location(in: mapView)
      let rect = CGRect(x: point.x - 30, y: point.y - 30, width: 60, height: 60)
      let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: Set(["marker-layer"]))

      if let feature = features.first,
         let markerId = feature.attribute(forKey: "id") as? String,
         let isDraggable = feature.attribute(forKey: "draggable") as? Bool,
         isDraggable {
        draggedMarkerId = markerId
      }
    } else if sender.state == .ended {
      if let currentId = draggedMarkerId {
        let centerCoord = mapView.centerCoordinate
        onMarkerDragEnd?(currentId, centerCoord.latitude, centerCoord.longitude)
        draggedMarkerId = nil
      }
    }
  }

  private func updateCamera() {
    guard let lat = _latitude, let lng = _longitude, mapLoaded else { return }
    DispatchQueue.main.async {
      self.mapView.setCenter(
        CLLocationCoordinate2D(latitude: lat, longitude: lng),
        zoomLevel: self._zoom ?? 12.0,
        direction: self._bearing ?? 0.0,
        animated: false
      )

      let camera = self.mapView.camera
      camera.pitch = CGFloat(self._tilt ?? 0.0)
      self.mapView.setCamera(camera, animated: false)
    }
  }

  public func animateCamera(latitude: Double, longitude: Double, zoom: Double?, durationMs: Double?) {
    guard mapLoaded else { return }
    let targetZoom = zoom ?? _zoom ?? 12.0
    let duration = durationMs != nil ? durationMs! / 1000.0 : 1.0

    DispatchQueue.main.async {
      let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      self.mapView.setCenter(center, zoomLevel: targetZoom, direction: self._bearing ?? 0.0, animated: false)
      let camera = self.mapView.camera
      camera.pitch = CGFloat(self._tilt ?? 0.0)
      self.mapView.setCamera(camera, withDuration: TimeInterval(duration), animationTimingFunction: nil)
    }
  }

  public func fitBounds(coordinates: [LatLng], padding: Double?) {
    guard mapLoaded, !coordinates.isEmpty else { return }
    DispatchQueue.main.async {
      let coords = coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
      var bounds = MLNCoordinateBounds(sw: coords[0], ne: coords[0])
      for coord in coords {
        bounds.sw.latitude = min(bounds.sw.latitude, coord.latitude)
        bounds.sw.longitude = min(bounds.sw.longitude, coord.longitude)
        bounds.ne.latitude = max(bounds.ne.latitude, coord.latitude)
        bounds.ne.longitude = max(bounds.ne.longitude, coord.longitude)
      }
      let pad = UIEdgeInsets(top: CGFloat(padding ?? 100), left: CGFloat(padding ?? 100), bottom: CGFloat(padding ?? 100), right: CGFloat(padding ?? 100))
      self.mapView.setVisibleCoordinateBounds(bounds, edgePadding: pad, animated: true)
    }
  }

  public func downloadOfflineRegion(swLat: Double, swLng: Double, neLat: Double, neLng: Double, minZoom: Double, maxZoom: Double, regionName: String) {
    DispatchQueue.main.async {
      guard let styleURL = self.mapView.styleURL else { return }
      let bounds = MLNCoordinateBounds(sw: CLLocationCoordinate2D(latitude: swLat, longitude: swLng), ne: CLLocationCoordinate2D(latitude: neLat, longitude: neLng))

      let region = MLNTilePyramidOfflineRegion(styleURL: styleURL, bounds: bounds, fromZoomLevel: minZoom, toZoomLevel: maxZoom)
      let contextData = regionName.data(using: .utf8)

      MLNOfflineStorage.shared.addPack(for: region, withContext: contextData ?? Data()) { (pack, error) in
        pack?.resume()
      }
    }
  }

  // MARK: - Route fetching (mirrors Android fetchAndDrawRouteNative)
  private func fetchAndDrawRouteNative(originLat: Double, originLng: Double, destLat: Double, destLng: Double) {
    guard mapLoaded else { return }

    let urlStr = "https://router.project-osrm.org/route/v1/driving/\(originLng),\(originLat);\(destLng),\(destLat)?geometries=geojson&overview=full"
    guard let url = URL(string: urlStr) else { return }

    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      guard let self = self else { return }
      guard let data = data, error == nil else { return }

      do {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let routes = json["routes"] as? [[String: Any]],
              let firstRoute = routes.first,
              let geometry = firstRoute["geometry"] as? [String: Any],
              let coords = geometry["coordinates"] as? [[Double]] else { return }

        let routeCoords: [LatLng] = coords.map { LatLng(latitude: $0[1], longitude: $0[0]) }

        let newPoly = Polyline(
          id: "osrm_route_\(Int(Date().timeIntervalSince1970))",
          coordinates: routeCoords,
          color: "#3388FF",
          width: 6.0
        )

        DispatchQueue.main.async {
          self._polylines?.removeAll { $0.id.hasPrefix("osrm_route_") }
          self._polylines?.append(newPoly)
          self.updatePolylines()
        }
      } catch {
        print("Route parse error: \(error)")
      }
    }
    task.resume()
  }

  private func updateMarkers() {
    guard mapLoaded else { return }
    let markersArray = _markers ?? []

    for marker in markersArray {
      if let img = marker.iconImage, img.hasPrefix("http://") || img.hasPrefix("https://") {
        downloadAndAddImage(urlStr: img)
      }
    }

    guard let style = mapView.style, let source = style.source(withIdentifier: "marker-source") as? MLNShapeSource else { return }
    var features: [MLNPointFeature] = []

    for marker in markersArray {
      let feature = MLNPointFeature()
      feature.coordinate = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
      feature.attributes = [
        "id": marker.id ?? "",
        "title": marker.title ?? "",
        "snippet": marker.snippet ?? "",
        "rating": marker.rating ?? "",
        "eta": marker.eta ?? "",
        "color": marker.color ?? "#FF0000",
        "iconImage": marker.iconImage ?? "default_marker_icon",
        "rotation": marker.rotation ?? 0.0,
        "draggable": marker.draggable ?? false
      ]
      features.append(feature)
    }
    source.shape = MLNShapeCollection(shapes: features)
  }

  private func updateVehicleMarker() {
    guard let vehicle = _vehicleMarker, mapLoaded else { return }

    if let img = vehicle.iconImage, img.hasPrefix("http://") || img.hasPrefix("https://") {
      downloadAndAddImage(urlStr: img)
    }

    guard let style = mapView.style, let source = style.source(withIdentifier: "vehicle-source") as? MLNShapeSource else { return }
    let feature = MLNPointFeature()
    feature.coordinate = CLLocationCoordinate2D(latitude: vehicle.latitude, longitude: vehicle.longitude)
    feature.attributes = [
      "id": vehicle.id ?? "live_vehicle",
      "title": vehicle.title ?? "",
      "iconImage": vehicle.iconImage ?? "default_marker_icon",
      "rotation": vehicle.rotation ?? 0.0
    ]
    source.shape = feature
  }

  private func updatePolylines() {
    guard let style = mapView.style, let source = style.source(withIdentifier: "polyline-source") as? MLNShapeSource, mapLoaded else { return }
    var mPolylines: [MLNPolyline] = []
    let lines = _polylines ?? []
    for poly in lines {
      var coords = poly.coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
      let polyline = MLNPolyline(coordinates: &coords, count: UInt(coords.count))
      mPolylines.append(polyline)
    }
    source.shape = MLNShapeCollection(shapes: mPolylines)

    if let firstPoly = lines.last, let layer = style.layer(withIdentifier: "polyline-layer") as? MLNLineStyleLayer {
      if let colorStr = firstPoly.color, !colorStr.isEmpty {
        layer.lineColor = NSExpression(forConstantValue: parseColor(colorStr))
      }
      if let width = firstPoly.width {
        layer.lineWidth = NSExpression(forConstantValue: CGFloat(width))
      }
    }
  }

  private func updatePolygons() {
    guard let style = mapView.style, let source = style.source(withIdentifier: "polygon-source") as? MLNShapeSource, mapLoaded else { return }
    var mPolygons: [MLNPolygon] = []
    let polys = _polygons ?? []
    for poly in polys {
      var coords = poly.coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
      let polygon = MLNPolygon(coordinates: &coords, count: UInt(coords.count))
      mPolygons.append(polygon)
    }
    source.shape = MLNShapeCollection(shapes: mPolygons)

    if let firstPoly = polys.first, let layer = style.layer(withIdentifier: "polygon-layer") as? MLNFillStyleLayer {
      if let fillColor = firstPoly.fillColor, !fillColor.isEmpty {
        layer.fillColor = NSExpression(forConstantValue: parseColor(fillColor))
      }
      if let strokeColor = firstPoly.strokeColor, !strokeColor.isEmpty {
        layer.fillOutlineColor = NSExpression(forConstantValue: parseColor(strokeColor))
      }
    }
  }

  private func updateUserLocationState() {
    mapView.showsUserLocation = _showUserLocation ?? false
  }

  // Safe Image Downloading Taaki Main Thread Par properly attach ho sake
  private func downloadAndAddImage(urlStr: String) {
    guard let style = mapView.style, style.image(forName: urlStr) == nil else { return }

    DispatchQueue.global(qos: .background).async {
      guard let url = URL(string: urlStr),
            let data = try? Data(contentsOf: url),
            let downloadedImage = UIImage(data: data) else { return }

      DispatchQueue.main.async {
        if let currentStyle = self.mapView.style, currentStyle.image(forName: urlStr) == nil {
          currentStyle.setImage(downloadedImage.withRenderingMode(.alwaysOriginal), forName: urlStr)

          self.updateMarkers()
          self.updateVehicleMarker()
        }
      }
    }
  }

  // MARK: - Powerful Color Parser
  public func parseColor(_ colorStr: String) -> UIColor {
    let formattedStr = colorStr.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    if formattedStr.hasPrefix("rgba") || formattedStr.hasPrefix("rgb") {
        let characterSet = CharacterSet(charactersIn: "0123456789.")
        let numbers = formattedStr.components(separatedBy: characterSet.inverted).filter { !$0.isEmpty }

        if numbers.count >= 3 {
            let r = CGFloat(Double(numbers[0]) ?? 0) / 255.0
            let g = CGFloat(Double(numbers[1]) ?? 0) / 255.0
            let b = CGFloat(Double(numbers[2]) ?? 0) / 255.0
            let a = numbers.count >= 4 ? CGFloat(Double(numbers[3]) ?? 1.0) : 1.0
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }

    var hex = formattedStr
    if hex.hasPrefix("#") {
        hex.removeFirst()
    }

    var rgbValue: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&rgbValue)

    if hex.count == 8 {
        return UIColor(
            red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
            alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        )
    } else if hex.count == 6 {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }

    return UIColor.gray
  }
}