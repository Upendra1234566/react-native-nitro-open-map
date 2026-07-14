package com.margelo.nitro.nitroopenmap

import android.view.View
import androidx.core.graphics.toColorInt
import com.facebook.proguard.annotations.DoNotStrip
import com.facebook.react.uimanager.ThemedReactContext

import org.maplibre.android.MapLibre
import org.maplibre.android.maps.MapView


@DoNotStrip
class HybridNitroOpenMap(
    private val context: ThemedReactContext
) : HybridNitroOpenMapSpec() {


    private val mapView: MapView


    override val view: View
        get() = mapView


    private var _color = "#ffffff"


    override var color: String
        get() = _color
        set(value) {
            _color = value
            mapView.setBackgroundColor(
                value.toColorInt()
            )
        }


    init {

        MapLibre.getInstance(
            context.applicationContext
        )

        mapView = MapView(context)


        mapView.getMapAsync { map ->

            map.setStyle(
                "https://demotiles.maplibre.org/style.json"
            )

        }
    }
}