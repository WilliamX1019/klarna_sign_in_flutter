import Flutter
import UIKit
import KlarnaMobileSDK
import AuthenticationServices

public class KlarnaSignInFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, KlarnaEventHandler, ASWebAuthenticationPresentationContextProviding {

    private var eventSink: FlutterEventSink?
    private var sdk: KlarnaSignInSDK?

    private var returnUrl: URL?
    private var environment: KlarnaEnvironment = .playground
    private var region: KlarnaRegion = .na
    private var theme: KlarnaTheme = .light

   nonisolated public static func register(with registrar: FlutterPluginRegistrar) {
        let method = FlutterMethodChannel(name: "klarna_signin/methods", binaryMessenger: registrar.messenger())
        let events = FlutterEventChannel(name: "klarna_signin/events", binaryMessenger: registrar.messenger())

        let instance = KlarnaSignInFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: method)
        events.setStreamHandler(instance)
    }

    // FlutterStreamHandler
   nonisolated public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
   nonisolated public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    // Flutter Method Calls
   nonisolated public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any], let returnUrlStr = args["returnUrl"] as? String, let url = URL(string: returnUrlStr) else {
                result(FlutterError(code: "ARG_ERROR", message: "returnUrl missing", details: nil))
                return
            }
            returnUrl = url

            if let env = (args["environment"] as? String)?.lowercased() {
                environment = env == "production" ? .production : .playground
            }
            if let reg = (args["region"] as? String)?.uppercased() {
                switch reg { case "NA": region = .na; case "OC": region = .oc; default: region = .eu }
            }
            if let th = (args["theme"] as? String)?.lowercased() {
                switch th { case "light": theme = .light; case "dark": theme = .dark; default: theme = .automatic }
            }

            sdk = KlarnaSignInSDK(theme: theme, environment: environment, region: region, returnUrl: url, eventHandler: self)
            result(nil)

        case "signIn":
            guard let args = call.arguments as? [String: Any],
                  let clientId = args["clientId"] as? String,
                  let scope = args["scope"] as? String,
                  let market = args["market"] as? String else {
                result(FlutterError(code: "ARG_ERROR", message: "missing signIn args", details: nil))
                return
            }
            let locale = args["locale"] as? String

            guard let s = sdk else {
                result(FlutterError(code: "NOT_INITIALIZED", message: "Call initialize() first", details: nil))
                return
            }

            s.signIn(
                clientId: clientId,
                scope: scope,
                market: market,
                locale: locale,
                presentationContext: self
            )
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // KlarnaEventHandler
   nonisolated public func klarnaComponent(_ klarnaComponent: KlarnaComponent, dispatchedEvent event: KlarnaProductEvent) {
        var map: [String: Any] = ["action": event.action]
        map["params"] = event.params
        eventSink?(map)
    }
   nonisolated public func klarnaComponent(_ klarnaComponent: KlarnaComponent, encounteredError error: KlarnaError) {
        var map: [String: Any] = ["action": "ERROR"]
        map["params"] = ["message": error.localizedDescription]
        eventSink?(map)
    }
    // ASWebAuthenticationPresentationContextProviding
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let key = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return key
        }
        return UIApplication.shared.windows.first ?? UIWindow()
    }
}