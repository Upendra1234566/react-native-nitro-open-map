
package com.margelo.nitro.nitroopenmap

import android.graphics.Color
import android.graphics.BitmapFactory
import android.graphics.RectF
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.FrameLayout
import androidx.core.graphics.toColorInt
import com.facebook.proguard.annotations.DoNotStrip
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.uimanager.ThemedReactContext
import com.margelo.nitro.core.Promise
import org.maplibre.android.MapLibre
import org.maplibre.android.camera.CameraPosition
import org.maplibre.android.camera.CameraUpdateFactory
import org.maplibre.android.geometry.LatLng
import org.maplibre.android.geometry.LatLngBounds
import org.maplibre.android.maps.MapLibreMap
import org.maplibre.android.maps.MapLibreMapOptions
import org.maplibre.android.maps.MapView
import org.maplibre.android.style.layers.SymbolLayer
import org.maplibre.android.style.layers.LineLayer
import org.maplibre.android.style.layers.FillLayer
import org.maplibre.android.style.layers.CircleLayer
import org.maplibre.android.style.layers.Property
import org.maplibre.android.style.layers.PropertyFactory
import org.maplibre.android.style.sources.GeoJsonSource
import org.maplibre.android.style.sources.GeoJsonOptions
import org.maplibre.android.style.expressions.Expression
import org.maplibre.android.location.LocationComponentActivationOptions
import org.maplibre.android.location.permissions.PermissionsManager
import org.maplibre.android.gestures.MoveGestureDetector
import org.maplibre.android.offline.OfflineRegion
import org.maplibre.android.offline.OfflineRegionError
import org.maplibre.android.offline.OfflineRegionStatus
import org.maplibre.android.offline.OfflineManager
import org.maplibre.android.offline.OfflineTilePyramidRegionDefinition
import org.json.JSONObject
import java.net.URL
import java.net.HttpURLConnection
import kotlinx.coroutines.*

@DoNotStrip
class HybridNitroOpenMap(private val context: ThemedReactContext) : HybridNitroOpenMapSpec(), LifecycleEventListener {

    private val wrapperView: FrameLayout
    private val mapView: MapView
    private var mapLibreMap: MapLibreMap? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private var _color = "#FFFFFF"
    private var _latitude: Double? = null
    private var _longitude: Double? = null
    private var _zoom: Double = 12.0
    private var _bearing: Double = 0.0
    private var _tilt: Double = 0.0
    private var _mapStyle: String = "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
    private var _markers: List<Marker> = emptyList()
    private var _showUserLocation: Boolean = false
    private var _vehicleMarker: Marker? = null
    private var _fitBoundsCoords: List<LatLng>? = null
    private var _polylines: MutableList<Polyline> = mutableListOf()
    private var _polygons: List<Polygon> = emptyList()
    private var _routeRequest: RouteRequest? = null
    
    // Callbacks & Listeners
    private var _onMarkerPress: ((String) -> Unit)? = null
    private var _onMarkerDragEnd: ((String, Double, Double) -> Unit)? = null
    private var _onMapReady: (() -> Unit)? = null

    private var draggedMarkerId: String? = null
    private var mapLoaded = false

    override val view: View get() = wrapperView

    override var color: String
        get() = _color
        set(value) {
            _color = value
            mainHandler.post { 
                try { wrapperView.setBackgroundColor(value.toColorInt()) } 
                catch (_: Exception) { wrapperView.setBackgroundColor(Color.WHITE) }
            }
        }

    override var latitude: Double?
        get() = _latitude
        set(value) { _latitude = value; updateCamera() }

    override var longitude: Double?
        get() = _longitude
        set(value) { _longitude = value; updateCamera() }

    override var zoom: Double?
        get() = _zoom
        set(value) { _zoom = value ?: 12.0; updateCamera() }

    override var bearing: Double?
        get() = _bearing
        set(value) { _bearing = value ?: 0.0; updateCamera() }

    override var tilt: Double?
        get() = _tilt
        set(value) { _tilt = value ?: 0.0; updateCamera() }

    override var mapStyle: String?
        get() = _mapStyle
        set(value) {
            _mapStyle = value ?: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
            mainHandler.post { mapLibreMap?.setStyle(_mapStyle) }
        }

    override var markers: Array<Marker>?
        get() = _markers.toTypedArray()
        set(value) {
            _markers = value?.toList() ?: emptyList()
            updateMarkers()
        }

    override var showUserLocation: Boolean?
        get() = _showUserLocation
        set(value) {
            _showUserLocation = value ?: false
            updateUserLocationState()
        }

    override var vehicleMarker: Marker?
        get() = _vehicleMarker
        set(value) {
            _vehicleMarker = value
            updateVehicleMarker()
        }

    override var fitBoundsCoords: Array<com.margelo.nitro.nitroopenmap.LatLng>?
        get() = _fitBoundsCoords?.map { com.margelo.nitro.nitroopenmap.LatLng(it.latitude, it.longitude) }?.toTypedArray()
        set(value) {
            _fitBoundsCoords = value?.map { LatLng(it.latitude, it.longitude) }
            if (!_fitBoundsCoords.isNullOrEmpty()) {
                fitBounds(_fitBoundsCoords!!.map { com.margelo.nitro.nitroopenmap.LatLng(it.latitude, it.longitude) }.toTypedArray(), 100.0)
            }
        }

    override var polylines: Array<Polyline>?
        get() = _polylines.toTypedArray()
        set(value) {
            _polylines = value?.toMutableList() ?: mutableListOf()
            updatePolylines()
        }

    override var polygons: Array<Polygon>?
        get() = _polygons.toTypedArray()
        set(value) {
            _polygons = value?.toList() ?: emptyList()
            updatePolygons()
        }

    override var routeRequest: RouteRequest?
        get() = _routeRequest
        set(value) {
            _routeRequest = value
            if (value != null) {
                fetchAndDrawRouteNative(value.originLat, value.originLng, value.destLat, value.destLng)
            }
        }

    override var onMarkerPress: ((String) -> Unit)?
        get() = _onMarkerPress
        set(value) { _onMarkerPress = value }

    override var onMarkerDragEnd: ((String, Double, Double) -> Unit)?
        get() = _onMarkerDragEnd
        set(value) { _onMarkerDragEnd = value }

    override var onMapReady: (() -> Unit)?
        get() = _onMapReady
        set(value) {
            _onMapReady = value
            if (mapLoaded) {
                mainHandler.post { value?.invoke() }
            }
        }

    init {
        MapLibre.getInstance(context.applicationContext)
        wrapperView = FrameLayout(context)
        val options = MapLibreMapOptions.createFromAttributes(context).textureMode(true)
        mapView = MapView(context, options)
        wrapperView.addView(mapView)
        context.addLifecycleEventListener(this)

        mainHandler.post {
            mapView.onCreate(null)
            mapView.onStart()
            mapView.onResume()
            mapView.getMapAsync { map ->
                mapLibreMap = map
                map.setStyle(_mapStyle) { style ->
                    try {
                        val resourceId = context.resources.getIdentifier("ic_launcher", "mipmap", context.packageName)
                        if (resourceId != 0) {
                            val bitmap = BitmapFactory.decodeResource(context.resources, resourceId)
                            if (bitmap != null) {
                                style.addImage("default_marker_icon", bitmap)
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    style.addSource(GeoJsonSource("polygon-source"))
                    style.addLayer(
                        FillLayer("polygon-layer", "polygon-source")
                            .withProperties(
                                PropertyFactory.fillColor(Color.parseColor("#33FF0000")),
                                PropertyFactory.fillOutlineColor(Color.parseColor("#FF0000"))
                            )
                    )

                    style.addSource(GeoJsonSource("polyline-source"))
                    style.addLayer(
                        LineLayer("polyline-layer", "polyline-source")
                            .withProperties(
                                PropertyFactory.lineColor(Color.parseColor("#FF0000")),
                                PropertyFactory.lineWidth(5f)
                            )
                    )

                    val clusterOptions = GeoJsonOptions()
                        .withCluster(true)
                        .withClusterMaxZoom(14)
                        .withClusterRadius(50)

                    style.addSource(GeoJsonSource("marker-source", clusterOptions))

                    style.addLayer(
                        CircleLayer("cluster-circle-layer", "marker-source")
                            .withProperties(
                                PropertyFactory.circleColor(Color.parseColor("#FF5722")),
                                PropertyFactory.circleRadius(18f),
                                PropertyFactory.circleStrokeWidth(2f),
                                PropertyFactory.circleStrokeColor(Color.WHITE)
                            )
                            .withFilter(Expression.has("point_count"))
                    )

                    style.addLayer(
                        SymbolLayer("cluster-count-layer", "marker-source")
                            .withProperties(
                                PropertyFactory.textField("{point_count}"),
                                PropertyFactory.textSize(12f),
                                PropertyFactory.textColor(Color.WHITE),
                                PropertyFactory.textAnchor(Property.TEXT_ANCHOR_CENTER),
                                PropertyFactory.textJustify(Property.TEXT_JUSTIFY_CENTER)
                            )
                            .withFilter(Expression.has("point_count"))
                    )

                    style.addLayer(
                        SymbolLayer("marker-layer", "marker-source")
                            .withProperties(
                                PropertyFactory.textField("{title}"),
                                PropertyFactory.textSize(14f),
                                PropertyFactory.textColor(Color.BLACK),
                                PropertyFactory.textOffset(arrayOf(0f, 1.8f)),
                                PropertyFactory.textAnchor("top"),
                                PropertyFactory.iconImage("{iconImage}"),
                                PropertyFactory.iconSize(0.25f),
                                PropertyFactory.iconRotate(Expression.get("rotation")),
                                PropertyFactory.iconRotationAlignment(Property.ICON_ROTATION_ALIGNMENT_MAP),
                                PropertyFactory.iconAllowOverlap(true),
                                PropertyFactory.textAllowOverlap(false)
                            )
                            .withFilter(Expression.not(Expression.has("point_count")))
                    )

                    style.addSource(GeoJsonSource("vehicle-source"))
                    style.addLayer(
                        SymbolLayer("vehicle-layer", "vehicle-source")
                            .withProperties(
                                PropertyFactory.textField("{title}"),
                                PropertyFactory.textSize(14f),
                                PropertyFactory.textColor(Color.BLUE),
                                PropertyFactory.textOffset(arrayOf(0f, 1.8f)),
                                PropertyFactory.textAnchor("top"),
                                PropertyFactory.iconImage("{iconImage}"),
                                PropertyFactory.iconSize(0.3f),
                                PropertyFactory.iconRotate(Expression.get("rotation")),
                                PropertyFactory.iconRotationAlignment(Property.ICON_ROTATION_ALIGNMENT_MAP),
                                PropertyFactory.iconAllowOverlap(true),
                                PropertyFactory.textAllowOverlap(false)
                            )
                    )

                    mapLoaded = true
                    _onMapReady?.invoke()
                    updateCamera()
                    updateMarkers()
                    updateUserLocationState()
                    updateVehicleMarker()
                    updatePolylines()
                    updatePolygons()
                }

                map.addOnMapClickListener { point ->
                    val pixel = map.projection.toScreenLocation(point)
                    val rect = RectF(pixel.x - 50f, pixel.y - 50f, pixel.x + 50f, pixel.y + 50f)
                    val features = map.queryRenderedFeatures(rect, "marker-layer", "vehicle-layer", "cluster-circle-layer")
                    
                    if (features.isNotEmpty()) {
                        val clickedFeature = features[0]
                        val markerId = clickedFeature.getStringProperty("id")
                        if (!markerId.isNullOrEmpty()) {
                            _onMarkerPress?.invoke(markerId)
                            return@addOnMapClickListener true
                        }
                    }
                    false
                }

                map.addOnMapLongClickListener { point ->
                    val pixel = map.projection.toScreenLocation(point)
                    val rect = RectF(pixel.x - 60f, pixel.y - 60f, pixel.x + 60f, pixel.y + 60f)
                    val features = map.queryRenderedFeatures(rect, "marker-layer")

                    if (features.isNotEmpty()) {
                        val clickedFeature = features[0]
                        val markerId = clickedFeature.getStringProperty("id")
                        val isDraggable = clickedFeature.getBooleanProperty("draggable") ?: false
                        
                        if (!markerId.isNullOrEmpty() && isDraggable) {
                            draggedMarkerId = markerId
                            return@addOnMapLongClickListener true
                        }
                    }
                    false
                }

                map.addOnMoveListener(object : MapLibreMap.OnMoveListener {
                    override fun onMoveBegin(detector: MoveGestureDetector) {}
                    override fun onMove(detector: MoveGestureDetector) {}
                    override fun onMoveEnd(detector: MoveGestureDetector) {
                        val currentId = draggedMarkerId
                        if (currentId != null) {
                            val center = map.cameraPosition.target
                            if (center != null) {
                                _onMarkerDragEnd?.invoke(currentId, center.latitude, center.longitude)
                            }
                            draggedMarkerId = null
                        }
                    }
                })
            }
        }
    }

    override fun isMapReady(): Promise<Boolean> {
        return Promise.resolved(mapLoaded)
    }

    override fun downloadOfflineRegion(
        swLat: Double,
        swLng: Double,
        neLat: Double,
        neLng: Double,
        minZoom: Double,
        maxZoom: Double,
        regionName: String
    ) {
        val map = mapLibreMap ?: return
        if (!mapLoaded) return

        mainHandler.post {
            map.style?.url?.let { styleUrl ->
                val bounds = LatLngBounds.Builder()
                    .include(LatLng(neLat, neLng))
                    .include(LatLng(swLat, swLng))
                    .build()

                val definition = OfflineTilePyramidRegionDefinition(
                    styleUrl,
                    bounds,
                    minZoom,
                    maxZoom,
                    context.resources.displayMetrics.density
                )

                val metadataJson = JSONObject().apply {
                    put("NAME", regionName)
                }
                val metadata = metadataJson.toString().toByteArray(Charsets.UTF_8)

                val offlineManager = OfflineManager.getInstance(context.applicationContext)
                offlineManager.createOfflineRegion(
                    definition,
                    metadata,
                    object : OfflineManager.CreateOfflineRegionCallback {
                        override fun onCreate(offlineRegion: OfflineRegion) {
                            offlineRegion.setDownloadState(OfflineRegion.STATE_ACTIVE)
                            offlineRegion.setObserver(object : OfflineRegion.OfflineRegionObserver {
                                override fun onStatusChanged(status: OfflineRegionStatus) {
                                    if (status.isComplete) {
                                        // Download complete logic if needed
                                    }
                                }
                                override fun onError(error: OfflineRegionError) {}
                                override fun mapboxTileCountLimitExceeded(limit: Long) {}
                            })
                        }
                        override fun onError(error: String) {}
                    }
                )
            }
        }
    }

    private fun fetchAndDrawRouteNative(originLat: Double, originLng: Double, destLat: Double, destLng: Double) {
        if (!mapLoaded) return

        coroutineScope.launch(Dispatchers.IO) {
            try {
                val urlStr = "https://router.project-osrm.org/route/v1/driving/$originLng,$originLat;$destLng,$destLat?geometries=geojson&overview=full"
                val url = URL(urlStr)
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "GET"

                if (connection.responseCode == 200) {
                    val response = connection.inputStream.bufferedReader().use { it.readText() }
                    val json = JSONObject(response)
                    val routes = json.optJSONArray("routes")

                    if (routes != null && routes.length() > 0) {
                        val route = routes.getJSONObject(0)
                        val geometry = route.getJSONObject("geometry")
                        val coordinates = geometry.getJSONArray("coordinates")

                        val routeCoords = ArrayList<com.margelo.nitro.nitroopenmap.LatLng>()
                        for (i in 0 until coordinates.length()) {
                            val pt = coordinates.getJSONArray(i)
                            routeCoords.add(com.margelo.nitro.nitroopenmap.LatLng(pt.getDouble(1), pt.getDouble(0)))
                        }

                        val newPoly = Polyline(
                            id = "osrm_route_${System.currentTimeMillis()}",
                            coordinates = routeCoords.toTypedArray(),
                            color = "#3388FF",
                            width = 6.0
                        )

                        _polylines.removeAll { it.id?.startsWith("osrm_route_") == true }
                        _polylines.add(newPoly)
                        
                        withContext(Dispatchers.Main) {
                            updatePolylines()
                        }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun updateCamera() {
        val map = mapLibreMap ?: return
        val lat = _latitude ?: return
        val lng = _longitude ?: return
        if (!mapLoaded) return
        mainHandler.post {
            val position = CameraPosition.Builder()
                .target(LatLng(lat, lng))
                .zoom(_zoom)
                .bearing(_bearing)
                .tilt(_tilt)
                .build()
            map.moveCamera(CameraUpdateFactory.newCameraPosition(position))
        }
    }

    override fun animateCamera(latitude: Double, longitude: Double, zoom: Double?, durationMs: Double?) {
        val map = mapLibreMap ?: return
        if (!mapLoaded) return
        val targetZoom = zoom ?: _zoom
        val duration = durationMs?.toInt() ?: 1000

        mainHandler.post {
            val position = CameraPosition.Builder()
                .target(LatLng(latitude, longitude))
                .zoom(targetZoom)
                .bearing(_bearing)
                .tilt(_tilt)
                .build()
            map.animateCamera(CameraUpdateFactory.newCameraPosition(position), duration)
        }
    }

    override fun fitBounds(coordinates: Array<com.margelo.nitro.nitroopenmap.LatLng>, padding: Double?) {
        val map = mapLibreMap ?: return
        if (!mapLoaded || coordinates.isEmpty()) return
        val pad = padding?.toInt() ?: 100

        mainHandler.post {
            val builder = LatLngBounds.Builder()
            for (coord in coordinates) {
                builder.include(LatLng(coord.latitude, coord.longitude))
            }
            val bounds = builder.build()

            try {
                val cameraUpdate = CameraUpdateFactory.newLatLngBounds(bounds, pad)
                map.animateCamera(cameraUpdate, 1000)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun updateMarkers() {
        if (!mapLoaded) return
        _markers.forEach { marker ->
            val img = marker.iconImage
            if (!img.isNullOrEmpty() && (img.startsWith("http://") || img.startsWith("https://"))) {
                downloadAndAddImage(img)
            }
        }

        val features = _markers.joinToString(separator = ",", prefix = "{ \"type\": \"FeatureCollection\", \"features\": [", postfix = "] }") { marker ->
            val icon = if (marker.iconImage.isNullOrEmpty()) "default_marker_icon" else marker.iconImage!!
            """
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [${marker.longitude}, ${marker.latitude}]
              },
              "properties": {
                "id": "${marker.id ?: ""}",
                "title": "${marker.title ?: ""}",
                "snippet": "${marker.snippet ?: ""}",
                "rating": "${marker.rating ?: ""}",
                "eta": "${marker.eta ?: ""}",
                "color": "${marker.color ?: "#FF0000"}",
                "iconImage": "$icon",
                "rotation": ${marker.rotation ?: 0.0},
                "draggable": ${marker.draggable ?: false}
              }
            }
            """.trimIndent()
        }

        mainHandler.post {
            mapLibreMap?.getStyle { style ->
                val source = style.getSourceAs<GeoJsonSource>("marker-source")
                source?.setGeoJson(features)
            }
        }
    }

    private fun updateVehicleMarker() {
        val vehicle = _vehicleMarker ?: return
        if (!mapLoaded) return
        val img = vehicle.iconImage
        if (!img.isNullOrEmpty() && (img.startsWith("http://") || img.startsWith("https://"))) {
            downloadAndAddImage(img)
        }

        val icon = if (vehicle.iconImage.isNullOrEmpty()) "default_marker_icon" else vehicle.iconImage!!
        val featureJson = """
        {
          "type": "FeatureCollection",
          "features": [{
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [${vehicle.longitude}, ${vehicle.latitude}]
            },
            "properties": {
              "id": "${vehicle.id ?: "live_vehicle"}",
              "title": "${vehicle.title ?: ""}",
              "iconImage": "$icon",
              "rotation": ${vehicle.rotation ?: 0.0}
            }
          }]
        }
        """.trimIndent()

        mainHandler.post {
            mapLibreMap?.getStyle { style ->
                val source = style.getSourceAs<GeoJsonSource>("vehicle-source")
                source?.setGeoJson(featureJson)
            }
        }
    }

    private fun updatePolylines() {
        if (!mapLoaded) return
        val features = _polylines.joinToString(separator = ",", prefix = "{ \"type\": \"FeatureCollection\", \"features\": [", postfix = "] }") { poly ->
            val coordsStr = poly.coordinates.joinToString(separator = ",") { "[${it.longitude}, ${it.latitude}]" }
            """
            {
              "type": "Feature",
              "geometry": {
                "type": "LineString",
                "coordinates": [$coordsStr]
              },
              "properties": {
                "id": "${poly.id}"
              }
            }
            """.trimIndent()
        }

        mainHandler.post {
            mapLibreMap?.getStyle { style ->
                val source = style.getSourceAs<GeoJsonSource>("polyline-source")
                source?.setGeoJson(features)
                
                val layer = style.getLayerAs<LineLayer>("polyline-layer")
                if (_polylines.isNotEmpty()) {
                    val lastPoly = _polylines.last()
                    val polyColor = if (lastPoly.color.isNullOrEmpty()) "#3388FF" else lastPoly.color!!
                    val polyWidth = (lastPoly.width?.toFloat() ?: 5f)
                    try {
                        layer?.setProperties(
                            PropertyFactory.lineColor(Color.parseColor(polyColor)),
                            PropertyFactory.lineWidth(polyWidth)
                        )
                    } catch (e: Exception) { e.printStackTrace() }
                }
            }
        }
    }

    private fun updatePolygons() {
        if (!mapLoaded) return
        val features = _polygons.joinToString(separator = ",", prefix = "{ \"type\": \"FeatureCollection\", \"features\": [", postfix = "] }") { poly ->
            val coords = poly.coordinates.toMutableList()
            if (coords.isNotEmpty() && (coords.first().latitude != coords.last().latitude || coords.first().longitude != coords.last().longitude)) {
                coords.add(coords.first())
            }
            val coordsStr = coords.joinToString(separator = ",") { "[${it.longitude}, ${it.latitude}]" }
            """
            {
              "type": "Feature",
              "geometry": {
                "type": "Polygon",
                "coordinates": [[$coordsStr]]
              },
              "properties": {
                "id": "${poly.id}"
              }
            }
            """.trimIndent()
        }

        mainHandler.post {
            mapLibreMap?.getStyle { style ->
                val source = style.getSourceAs<GeoJsonSource>("polygon-source")
                source?.setGeoJson(features)

                val layer = style.getLayerAs<FillLayer>("polygon-layer")
                if (_polygons.isNotEmpty()) {
                    val firstPoly = _polygons.first()
                    val fillColor = if (firstPoly.fillColor.isNullOrEmpty()) "#33FF0000" else firstPoly.fillColor!!
                    val strokeColor = if (firstPoly.strokeColor.isNullOrEmpty()) "#FF0000" else firstPoly.strokeColor!!
                    try {
                        layer?.setProperties(
                            PropertyFactory.fillColor(Color.parseColor(fillColor)),
                            PropertyFactory.fillOutlineColor(Color.parseColor(strokeColor))
                        )
                    } catch (e: Exception) { e.printStackTrace() }
                }
            }
        }
    }

    private fun updateUserLocationState() {
        val map = mapLibreMap ?: return
        if (!mapLoaded) return
        mainHandler.post {
            map.getStyle { style ->
                if (_showUserLocation) {
                    if (PermissionsManager.areLocationPermissionsGranted(context)) {
                        try {
                            val locationComponent = map.locationComponent
                            locationComponent.activateLocationComponent(
                                LocationComponentActivationOptions.builder(context, style).build()
                            )
                            locationComponent.isLocationComponentEnabled = true
                        } catch (e: Exception) { e.printStackTrace() }
                    }
                } else {
                    try {
                        if (map.locationComponent.isLocationComponentEnabled) {
                            map.locationComponent.isLocationComponentEnabled = false
                        }
                    } catch (_: Exception) {}
                }
            }
        }
    }

    private fun downloadAndAddImage(urlStr: String) {
        mapLibreMap?.getStyle { style ->
            if (style.getImage(urlStr) == null) {
                coroutineScope.launch(Dispatchers.IO) {
                    try {
                        val url = URL(urlStr)
                        val bmp = BitmapFactory.decodeStream(url.openConnection().getInputStream())
                        if (bmp != null) {
                            withContext(Dispatchers.Main) {
                                mapLibreMap?.getStyle { currentStyle ->
                                    if (currentStyle.getImage(urlStr) == null) {
                                        currentStyle.addImage(urlStr, bmp)
                                        updateMarkers()
                                        updateVehicleMarker()
                                    }
                                }
                            }
                        }
                    } catch (e: Exception) { e.printStackTrace() }
                }
            }
        }
    }

    override fun onHostResume() { mainHandler.post { mapView.onResume() } }
    override fun onHostPause() { mainHandler.post { mapView.onPause() } }
    override fun onHostDestroy() { 
        coroutineScope.cancel()
        mainHandler.post { mapView.onDestroy() } 
    }
    
    override fun onDropView() {
        context.removeLifecycleEventListener(this)
        coroutineScope.cancel()
        mainHandler.post { mapView.onDestroy() }
        super.onDropView()
    }
}