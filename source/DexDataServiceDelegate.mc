using Toybox.Application;
using Toybox.Background;
using Toybox.Communications;
using Toybox.System;


(:background)
class DexDataServiceDelegate extends System.ServiceDelegate {

    function initialize() {
		System.println("ServiceDelegate.initialize");
		ServiceDelegate.initialize();
	}

    function onTemporalEvent() {
		System.println("ServiceDelegate.onTemporalEvent");
		self.makeRequest();
	}

    function makeRequest() as Void {
        System.println("ServiceDelegate.makeRequest");
        //var url = Application.getApp().getProperty("ApiUrl"); // set the url
        var url = Application.getApp().Properties.getValue("ApiUrl"); // set the url
        if (url) {
            url = stringReplace(url, " ", "");
        }
        System.println("ApiUrl: " + url);
        
        // var apiKey = Application.getApp().getProperty("ApiKey"); // set the api key
        var apiKey = Application.getApp().Properties.getValue("ApiKey"); // set the url
        if (apiKey) {
            apiKey = stringReplace(apiKey, " ", "");
        }
        System.println("ApiKey: " + apiKey);

        if (url == "" || apiKey == "") {
            System.println("No URL or Api key set"); 
            return;
        }
        if (url.substring(url.length()-1, url.length()) != '/') {
            url += '/';
        }
        url += "read_data";

        var options = {                                             // set the options
            :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
            :headers => {                                           // set headers
                "Content-Type" => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                "x-api-key" => apiKey
            },
            // set response type
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        var responseCallback = method(:onReceive);                  // set responseCallback to
        // Make the Communications.makeWebRequest() call
        Communications.makeWebRequest(url, {}, options, method(:onReceive));
    }

    // set up the response callback function
    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        System.println("ServiceDelegate.onReceive");
        System.println(data);
        var response = {};
        if (responseCode == 200) {
            System.println("Request Successful"); // print success
            response["success"] = true;
            response["data"] = data["entries"];
        } else if (responseCode == 404) {
            System.println("Response: " + responseCode); // print response code
            response["success"] = false;
            response["error_message"] = "Server not found";
        } else {
            System.println("Response: " + responseCode); // print response code
            response["success"] = false;
            if (data instanceof Dictionary && data.keys().indexOf("message") == -1) {
                response["error_message"] = data["message"];
            } else {
                response["error_message"] = "Unknown server error";
            }
        }

        System.println("Background.exit"); 
        Background.exit(response);
    }
}

(:background)
function stringReplace(str, oldString, newString) {
    var result = str;
    while (true) {
        var index = result.find(oldString);

        if (index != null) {
            var index2 = index+oldString.length();
            result = result.substring(0, index) + newString + result.substring(index2, result.length());
        } else {
            return result;
        }
    }
    return null;
}