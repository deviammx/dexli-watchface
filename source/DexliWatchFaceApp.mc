import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class DexliWatchFaceApp extends Application.AppBase {

    function initialize() {
        System.println("App.initialize");
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        // Application.getApp().Storage.setValue("dex_values_error", null);
        // Application.getApp().Storage.setValue("dex_values_sgv", null);
        // Application.getApp().Storage.setValue("dex_values_trend", null);
        // Application.getApp().Storage.setValue("dex_values_direction", null);
        // Application.getApp().Storage.setValue("dex_values_timestamp", null);
        System.println("App.onStart");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println("App.onStop");
        AppBase.onStop(state);
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        System.println("App.getInitialView");
        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        return [ new DexliWatchFaceView() ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        System.println("App.onSettingsChanged");
    }

    function getServiceDelegate() {
    	System.println("App.getServiceDelegate");
        // var tmp = new DexDataServiceDelegate();
        // tmp.makeRequest();
    	return [ new DexDataServiceDelegate() ];
    }

    function onBackgroundData(data) {
        System.println("App.onBackgroundData");
        System.println(data);
        // invalid response structure
        if (!(data instanceof Object) || data.keys().indexOf("success") == -1) {
            System.println("No valid data structure");
            // reset dex values, dex_values_error -> "invalid data"
            Application.getApp().Storage.setValue("dex_values_error", "invalid_data");
            return;
        }
        // request failed with error message
        if (data["success"] == false && data.keys().indexOf("error_message") != -1) {
            System.println(data["error_message"]);
            // reset dex values, dex_values_error -> "no data"
            Application.getApp().Storage.setValue("dex_values_error", data["error_message"]);
            return;
        }
        // request failed or no data object
        if (data["success"] == false || data.keys().indexOf("data") == -1 || data["data"].size() == 0) {
            System.println("No data");
            // reset dex values, dex_values_error -> "no data"
            Application.getApp().Storage.setValue("dex_values_error", "no_data");
            return;
        }
        Application.getApp().Storage.setValue("dex_values_error", "no_error");
        Application.getApp().Storage.setValue("dex_values_sgv", data["data"][0]["sgv"]);
        Application.getApp().Storage.setValue("dex_values_trend", data["data"][0]["trend"]);
        Application.getApp().Storage.setValue("dex_values_direction", data["data"][0]["direction"]);
        Application.getApp().Storage.setValue("dex_values_timestamp", data["data"][0]["date"]);
        
        // WatchUi.requestUpdate();
    }

}

function getApp() as DexliWatchFaceApp {
    return Application.getApp() as DexliWatchFaceApp;
}