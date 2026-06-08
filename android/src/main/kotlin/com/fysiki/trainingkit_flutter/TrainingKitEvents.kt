package com.fysiki.trainingkit_flutter

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Bridges TrainingKit workout lifecycle events to the Flutter event channel.
 *
 * The plugin wires this object as the channel's stream handler; the workout
 * activities — launched in their own task — push events through it. Events are
 * delivered on the main thread, as required by [EventChannel.EventSink].
 */
object TrainingKitEvents : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emitSave(dataJson: String) {
        emit(mapOf("type" to "save", "data" to dataJson))
    }

    fun emitQuit() {
        emit(mapOf("type" to "quit"))
    }

    fun emitEvent(name: String, propertiesJson: String) {
        emit(mapOf("type" to "event", "name" to name, "properties" to propertiesJson))
    }

    private fun emit(body: Map<String, Any?>) {
        val sink = sink ?: return
        mainHandler.post { sink.success(body) }
    }
}
