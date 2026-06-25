package com.fysiki.trainingkit_flutter

import android.app.Application
import android.content.Context
import android.content.Intent
import com.fizzup.trainingkit.TrainingKit
import com.fizzup.trainingkit.utils.DeviceIdHelper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Flutter bridge for FizzUp TrainingKit. */
class TrainingKitFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "trainingkit_flutter")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "trainingkit_flutter/events")
        eventChannel.setStreamHandler(TrainingKitEvents)

        (context as? Application)?.let { application ->
            TrainingKit.initialize(application)
        }
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result,
    ) {
        when (call.method) {
            "deviceIdentifier" -> result.success(DeviceIdHelper.getDeviceId(context))
            "launchClassicWorkout" -> launchWorkout(ClassicWorkoutActivity::class.java, call, result)
            "launchVideoWorkout" -> launchWorkout(VideoWorkoutActivity::class.java, call, result)
            else -> result.notImplemented()
        }
    }

    private fun launchWorkout(
        activity: Class<*>,
        call: MethodCall,
        result: Result,
    ) {
        val jsonString = call.argument<String>("jsonString")
        val token = call.argument<String>("token")

        if (jsonString == null || token == null) {
            result.error("invalid_arguments", "Expected jsonString and token arguments.", null)
            return
        }

        val intent =
            Intent(context, activity).apply {
                putExtra("jsonString", jsonString)
                putExtra("token", token)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        context.startActivity(intent)
        result.success(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
