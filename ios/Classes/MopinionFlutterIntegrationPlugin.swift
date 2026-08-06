import Flutter
import UIKit
import MopinionSDK

public class MopinionFlutterIntegrationPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    // statics for the Flutter message communication

    weak var registrar: FlutterPluginRegistrar?
    private var eventSink: FlutterEventSink? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let METHOD_CHANNEL_NAME = "MopinionFlutterBridge/native"    // flutter communication channel
        let EVENT_CHANNEL_NAME = "MopinionFlutterBridge/native/events"  // flutter event channel

        let channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = MopinionFlutterIntegrationPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    private let invalidArgError = MopinionFlutterIntegrationPluginError(code:"invalidArgs", message: "Invalid arguments.")

    // get the "active" uiviewcontroller via flutter or via the os or nil if there isn't one.
    func getViewController() -> UIViewController? {
        if let controller = self.registrar?.viewController {
            // flutter single-view method
            return controller
        } else if #available(iOS 13.0, *) {
            // otherwise try it directly via the OS scenes
            let activeScenes = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene}).filter({ $0.activationState == .foregroundActive })
            if !activeScenes.isEmpty {
                if #available(iOS 15.0, *),
                   let controller = activeScenes.first?.keyWindow?.rootViewController {
                    // from iOS 15, get a key window directly from the scene
                    return controller
                } else if let controller = activeScenes.first?.windows.first(where: \.isKeyWindow)?.rootViewController {
                    // iOS 13-14, must find a key window amongst the windows in the scene
                    return controller
                }
            }
        }

        if let controller = UIApplication.shared.delegate?.window??.rootViewController {
            // fallback for pre iOS 27/13 apps that only rely on app life cycle
            return controller
        }

        return nil  // no UIViewController, can also happen when it is not yet displaying a UIView.
    }

    private init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    // MARK: Flutter method handler
    
    // Actual message handler. Call this for instance from your (Flutter)AppDelegate
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let controller = self.getViewController() else {
            return
        }
        switch call.method {
            case MopinionFlutterAction.INIT_WITH_DEPLOYMENT.rawValue :
                initializeSdk(call: call, result: result)
                break
            case MopinionFlutterAction.TRIGGER_EVENT.rawValue:
                triggerEvent(controller:controller, call: call, result: result)
                break
            case MopinionFlutterAction.ADD_META_DATA.rawValue:
                addMetaData(controller: controller, call: call, result: result)
                break
            case MopinionFlutterAction.REMOVE_META_DATA.rawValue:
                self.removeMetadataWithKey(controller: controller, call: call, result: result)
                break
            case MopinionFlutterAction.REMOVE_ALL_META_DATA.rawValue:
                removeAllMetadata(result: result)
                break
            default:
                break
        }
    }

    // MARK: implementation of the Flutter methods

    private func initializeSdk(call: FlutterMethodCall, result: FlutterResult) {
        guard let deploymentKey = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.DEPLOYMENT_KEY.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.DEPLOYMENT_KEY.rawValue)", details: "Expected deployment key as String"))
            return
        }
        guard let flutterThemeMode = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.FLUTTER_THEME_MODE.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.FLUTTER_THEME_MODE.rawValue)", details: "Expected dark, light or system as String."))
            return
        }
        guard let enableLogging = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.LOG.rawValue] as? Bool else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.LOG.rawValue)", details: "Expected log to be bool (true or false)"))
            return
        }
        if flutterThemeMode.compare("dark", options: .caseInsensitive) == .orderedSame {
            MopinionSDK.configuration.setColorScheme(.dark)
        } else
        if flutterThemeMode.compare("light", options: .caseInsensitive) == .orderedSame {
            MopinionSDK.configuration.setColorScheme(.light)
        } else
        if flutterThemeMode.compare("system", options: .caseInsensitive) == .orderedSame {
            MopinionSDK.configuration.setColorScheme(.auto) // in iOS, auto is the default.
        }
        MopinionSDK.load(deploymentKey, enableLogging)
        result(nil)
    }

    private func triggerEvent(controller: UIViewController, call: FlutterMethodCall, result: FlutterResult) {
        guard let eventName = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.FIRST_ARGUMENT.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.FIRST_ARGUMENT.rawValue)", details: "Expected event name as String"))
            return
        }
        MopinionSDK.event(controller, eventName, onCallbackEvent: { mopinionEvent,response in
            guard let eventSink = self.eventSink else { return }
            switch mopinionEvent {
            case .FORM_CLOSED:
                eventSink("FormClosed")
            case .FORM_OPEN:
                eventSink("FormOpened")
            case .FORM_SENT:
                eventSink("FormSent")
            case .NO_FORM_WILL_OPEN:
                eventSink("HasNotBeenShown")
            @unknown default:
                break
            }
        }, onCallbackEventError: { mopinionEvent,response in
            if let error = response.getError() {
                print("FlutterPLugin -> Error in \(self): callback event error failure.")
            }
        })
        result(nil)
    }

    private func addMetaData(controller: UIViewController, call: FlutterMethodCall, result: FlutterResult) {
        guard let key = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.KEY.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.KEY.rawValue)", details: "Expected key value for map of metadata."))
            return
        }
        guard let value = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.VALUE.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.VALUE.rawValue)", details: "Expected value for map of metadata."))
            return
        }
        MopinionSDK.data(key, value)
        result(nil)
    }

    private func removeMetadataWithKey(controller: UIViewController, call: FlutterMethodCall, result: FlutterResult) {
        guard let key = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.KEY.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.KEY.rawValue)", details: "Expected key value for map of metadata."))
            return
        }
        MopinionSDK.removeData(forKey: key)
        result(nil)
    }

    private func removeAllMetadata(result: FlutterResult) {
        MopinionSDK.removeData()
        result(nil)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    private struct MopinionFlutterIntegrationPluginError {
        let code : String
        let message : String
        
        init(code: String, message: String) {
            self.code = code        // short keywword like errornumber or alphanumeric classification
            self.message = message  // brief human readable description of the error classication
        }
    }
    
    private enum MopinionFlutterAction: String {
        case INIT_WITH_DEPLOYMENT = "init_sdk"
        case ADD_META_DATA = "add_meta_data"
        case REMOVE_META_DATA = "remove_meta_data"
        case REMOVE_ALL_META_DATA = "remove_all_meta_data"
        case TRIGGER_EVENT = "trigger_event"
    }

    private enum MopinionFlutterArgument: String {
        case DEPLOYMENT_KEY = "deployment_key"
        case FIRST_ARGUMENT = "argument1"
        case FLUTTER_THEME_MODE = "flutter_theme_mode"
        case KEY = "key"
        case LOG = "log"
        case VALUE = "value"
    }
}
