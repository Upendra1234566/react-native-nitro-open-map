package com.margelo.nitro.nitroopenmap

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.uimanager.ViewManager

import com.margelo.nitro.nitroopenmap.views.HybridNitroOpenMapManager

class NitroOpenMapPackage : BaseReactPackage() {
    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
        return null
    }

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
        return ReactModuleInfoProvider { HashMap() }
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return listOf(HybridNitroOpenMapManager())
    }

    companion object {
        init {
            System.loadLibrary("nitroopenmap")
        }
    }
}
