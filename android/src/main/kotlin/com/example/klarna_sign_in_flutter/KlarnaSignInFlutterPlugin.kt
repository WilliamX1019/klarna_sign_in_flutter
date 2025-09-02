
package com.example.klarna_sign_in_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.MainThread
import com.klarna.mobile.sdk.api.KlarnaEventHandler
import com.klarna.mobile.sdk.api.KlarnaProductEvent
import com.klarna.mobile.sdk.api.KlarnaEnvironment
import com.klarna.mobile.sdk.api.KlarnaRegion
import com.klarna.mobile.sdk.api.KlarnaTheme
import com.klarna.mobile.sdk.api.signin.KlarnaSignInSDK
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.google.gson.Gson
class KlarnaSignInFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler, ActivityAware ,KlarnaEventHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    private var activity: Activity? = null
    private var context: Context? = null

    private var returnUrl: String? = null
    private var environment: KlarnaEnvironment = KlarnaEnvironment.PLAYGROUND
    private var region: KlarnaRegion = KlarnaRegion.EU
    private var theme: KlarnaTheme = KlarnaTheme.AUTOMATIC

    private var sdk: KlarnaSignInSDK? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "klarna_signin/methods")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "klarna_signin/events")
        eventChannel.setStreamHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }

    // EventChannel.StreamHandler
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { eventSink = events }
    override fun onCancel(arguments: Any?) { eventSink = null }

    // MethodChannel
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
          when (call.method) {
            "initialize" -> {
                val args = call.arguments as Map<*, *>
                returnUrl = args["returnUrl"] as String
                environment = when ((args["environment"] as String?)?.lowercase()) {
                    "production" -> KlarnaEnvironment.PRODUCTION
                    else -> KlarnaEnvironment.PLAYGROUND
                }
                region = when ((args["region"] as String?)?.uppercase()) {
                    "NA" -> KlarnaRegion.NA
                    "OC" -> KlarnaRegion.OC
                    else -> KlarnaRegion.EU
                }
                theme = when ((args["theme"] as String?)?.lowercase()) {
                    "light" -> KlarnaTheme.LIGHT
                    "dark" -> KlarnaTheme.DARK
                    else -> KlarnaTheme.AUTOMATIC
                }

                val act = activity
                val ret = returnUrl
                if (act != null && ret != null) {
                    sdk = KlarnaSignInSDK(
                        activity = act,
                        returnURL = ret,
                        eventHandler = this,
                        environment = environment,
                        region = region,
                        theme = theme
                    )
                    result.success(null)
                } else {
                    result.error("NO_ACTIVITY_OR_URL", "Activity or returnUrl missing", null)
                }
            }
            "signIn" -> {
                val args = call.arguments as Map<*, *>
                val clientId = args["clientId"] as String
                val scope = args["scope"] as String
                val market = args["market"] as String
                val locale = args["locale"] as String?

                val s = sdk
                if (s == null) {
                    result.error("NOT_INITIALIZED", "Call initialize() first", null)
                    return
                }

                s.signIn(
                    clientId = clientId,
                    scope = scope,
                    market = market,
                    locale = locale
                )
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }


    @MainThread
    override fun onEvent(klarnaComponent: com.klarna.mobile.sdk.api.component.KlarnaComponent, event: com.klarna.mobile.sdk.api.KlarnaProductEvent) {
        val map = HashMap<String, Any?>()
        val gson = Gson()
        val paramsMap: HashMap<String, Any?> = gson.fromJson(
            gson.toJson(event.params),
            HashMap::class.java
        ) as HashMap<String, Any?>

        map["action"] = event.action
        map["params"] = paramsMap
        eventSink?.success(map)
    }   
    @MainThread
    override fun onError(klarnaComponent: com.klarna.mobile.sdk.api.component.KlarnaComponent, error: com.klarna.mobile.sdk.KlarnaMobileSDKError) {
        val map = HashMap<String, Any?>()
        map["action"] = "ERROR"
        map["params"] = mapOf("message" to (error.message ?: error.toString()))
        eventSink?.success(map)
    }
}