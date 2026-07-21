
package com.margelo.nitro.nitroopenmap

import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.FrameLayout
import androidx.core.graphics.toColorInt
import com.facebook.proguard.annotations.DoNotStrip
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.uimanager.ThemedReactContext
import org.maplibre.android.MapLibre
import org.maplibre.android.camera.CameraPosition
import org.maplibre.android.camera.CameraUpdateFactory
import org.maplibre.android.geometry.LatLng
import org.maplibre.android.maps.MapLibreMap
import org.maplibre.android.maps.MapLibreMapOptions
import org.maplibre.android.maps.MapView
import org.maplibre.android.style.layers.SymbolLayer
import org.maplibre.android.style.layers.PropertyFactory
import org.maplibre.android.style.sources.GeoJsonSource

@DoNotStrip
class HybridNitroOpenMap(private val context: ThemedReactContext) : HybridNitroOpenMapSpec(), LifecycleEventListener {

    private val wrapperView: FrameLayout
    private val mapView: MapView
    private var mapLibreMap: MapLibreMap? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var _color = "#FFFFFF"
    private var _latitude: Double? = null
    private var _longitude: Double? = null
    private var _zoom: Double = 12.0
    private var _mapStyle: String = "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
    private var _markers: List<Marker> = emptyList()
    private var isMapReady = false

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
                    style.addSource(GeoJsonSource("marker-source"))
                    style.addLayer(SymbolLayer("marker-layer", "marker-source")
                        .withProperties(
                            PropertyFactory.textField("{title}"),
                            PropertyFactory.textSize(16f),
                            PropertyFactory.textColor(Color.BLACK)
                        ))
                    isMapReady = true
                    updateCamera()
                    updateMarkers()
                }
            }
        }
    }

    private fun updateCamera() {
        val map = mapLibreMap ?: return
        val lat = _latitude ?: return
        val lng = _longitude ?: return
        if (!isMapReady) return
        mainHandler.post {
            map.moveCamera(CameraUpdateFactory.newCameraPosition(
                CameraPosition.Builder().target(LatLng(lat, lng)).zoom(_zoom).build()))
        }
    }

    private fun updateMarkers() {
        if (!isMapReady) return
        
        // Convert list of markers to GeoJSON string manually
        val features = _markers.joinToString(separator = ",", prefix = "{ \"type\": \"FeatureCollection\", \"features\": [", postfix = "] }") { marker ->
            """
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [${marker.longitude}, ${marker.latitude}]
              },
              "properties": {
                "title": "${marker.title ?: ""}"
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

    override fun onHostResume() { mainHandler.post { mapView.onResume() } }
    override fun onHostPause() { mainHandler.post { mapView.onPause() } }
    override fun onHostDestroy() { mainHandler.post { mapView.onDestroy() } }
    override fun onDropView() {
        context.removeLifecycleEventListener(this)
        mainHandler.post { mapView.onDestroy() }
        super.onDropView()
    }
}