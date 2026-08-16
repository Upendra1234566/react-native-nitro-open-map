
import UIKit
import MapLibre
import NitroModules

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
  private var mapLoaded = false
  private var draggedMarkerId: String? = nil
  private var mapDelegateHelper: MapLibreDelegateHelper!

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

  public var onMarkerPress: ((String) -> Void)? = nil
  public var onMarkerDragEnd: ((String, Double, Double) -> Void)? = nil

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

  public override init() {
    wrapperView = UIView()
    mapView = MLNMapView(frame: .zero, styleURL: URL(string: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"))
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    wrapperView.addSubview(mapView)

    super.init()

    mapDelegateHelper = MapLibreDelegateHelper(parent: self)
    mapView.delegate = mapDelegateHelper
    mapView.showsUserLocation = false

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
    mapView.addGestureRecognizer(tapGesture)

    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMapLongPress(_:)))
    mapView.addGestureRecognizer(longPressGesture)
  }

  public func isMapReady() -> Promise<Bool> {
    return Promise.resolved(withResult: mapLoaded)
  }

  func onMapLoaded(style: MLNStyle) {
    mapLibreMap = style
    mapLoaded = true

    style.setImage(createDefaultMarkerImage(), forName: "default_marker_icon")
    setupLayersAndSources(style: style)

    DispatchQueue.main.async {
      self.updateCamera()
      self.updateMarkers()
      self.updatePolylines()
      self.updatePolygons()
      self.updateUserLocationState()
      self._onMapReady?()
    }
  }

  private func createDefaultMarkerImage() -> UIImage {
    let size = CGSize(width: 250, height: 250)
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
    
    context.setFillColor(UIColor.white.cgColor)
    context.fillEllipse(in: CGRect(x: 10, y: 10, width: 230, height: 230))
    
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

    // Standard marker source without clustering for free version
    let markerSource = MLNShapeSource(identifier: "marker-source", shape: nil, options: nil)
    style.addSource(markerSource)

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
    markerLayer.iconOptional = NSExpression(forConstantValue: true)
    markerLayer.textOptional = NSExpression(forConstantValue: true)
    
    style.addLayer(markerLayer)
  }

  @objc private func handleMapTap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: mapView)
    let rect = CGRect(x: point.x - 25, y: point.y - 25, width: 50, height: 50)
    let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: Set(["marker-layer"]))
    
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
        "iconImage": marker.iconImage ?? "default_marker_icon",
        "rotation": marker.rotation ?? 0.0,
        "draggable": marker.draggable ?? false
      ]
      features.append(feature)
    }
    source.shape = MLNShapeCollection(shapes: features)
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
        }
      }
    }
  }

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