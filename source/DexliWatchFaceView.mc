import Toybox.Application;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

class DexliWatchFaceView extends WatchUi.WatchFace {
    private var isFullyInitialized = false;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        
        setLayout(Rez.Layouts.WatchFace(dc));
        //load custom font
        // // // set clock font
        // var clockView = View.findDrawableById("TimeLabel") as Text;
        // clockView.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // clockView.drawText(clockView.position.x,clockView.position.y, font, "", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        var backgroundBitmap = View.findDrawableById("BackgroundBitmap");
        var backgroundImageId = Application.getApp().Properties.getValue("BackgroundImageId");

        if (backgroundImageId == 1) {
            backgroundBitmap.setBitmap(Rez.Drawables.Background1);
        } else if (backgroundImageId == 2) {
            backgroundBitmap.setBitmap(Rez.Drawables.Background2);
        } else if (backgroundImageId == 3) {
            backgroundBitmap.setBitmap(Rez.Drawables.Background3);
        } else {
            backgroundBitmap.setBitmap(Rez.Drawables.Background0);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var dateFormat = "$1$, $2$ $3$";
        var clockTime = System.getClockTime();
        // var clockTimeUTCOffset = clockTime.timeZoneOffset();
        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
        var dateString = Lang.format(dateFormat, [today.day_of_week, today.day, today.month]);

        // Update the timeView
        var timeView = View.findDrawableById("TimeLabel") as Text;
        var dateView = View.findDrawableById("DateLabel") as Text;
        var dexValueView = View.findDrawableById("DexValueLabel") as Text;
        var dexDetailsView = View.findDrawableById("DexDetailsLabel") as Text;

        var trendBitmap = View.findDrawableById("TrendBitmap");

        var dexError = Application.getApp().Storage.getValue("dex_values_error");
        var dexValueString = "";
        var dexDetailsString = "";

        System.println(dexError);
        if (dexError != null || !self.isFullyInitialized) {
            if ("no_error".equals(dexError) || !self.isFullyInitialized) {
                var svg_value = Application.getApp().Storage.getValue("dex_values_sgv");
                var trend_value = Application.getApp().Storage.getValue("dex_values_trend");

                if (svg_value != null) {
                    dexValueString = Lang.format("$1$ mg/dL", [svg_value]);
                    System.println(dexValueString);
                }

                if (trend_value != null) {
                    // Dexcom sends time as UTC
                    var dexTimeUTC = new Time.Moment(Application.getApp().Storage.getValue("dex_values_timestamp") / 1000);
                    System.println(dexTimeUTC.value());

                    // To calculate the time difference, we calculate current UTC time
                    var utcInfo = Time.Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
                    // Options for UTC
                    var options = {
                        :year   => utcInfo.year,
                        :month  => utcInfo.month,
                        :day    => utcInfo.day,
                        :hour   => utcInfo.hour,
                        :minute => utcInfo.min,
                        :second => utcInfo.sec
                    };
                    var utcNow = Time.Gregorian.moment(options);

                    System.println(utcNow.value());
                    var dexTimeDelta = utcNow.value()-dexTimeUTC.value();
                    System.println(dexTimeDelta);
                    var dexTimeDeltaMin = dexTimeDelta / 60;
                    System.println(dexTimeDeltaMin);
                    var duration = Math.floor(dexTimeDeltaMin);
                    System.println(dexTimeDeltaMin);

                    dexDetailsString = Lang.format("$1$     $2$", [
                        (trend_value > 0 ? "+" : "") + trend_value, 
                        (duration + " min")
                    ]);
                    System.println(dexDetailsString);
                }

                var direction = Application.getApp().Storage.getValue("dex_values_direction");

                if ("Flat".equals(direction)) {
                    trendBitmap.setBitmap(Rez.Drawables.TrendRight);
                } else if ("SingleUp".equals(direction) || "DoubleUp".equals(direction)) {
                    trendBitmap.setBitmap(Rez.Drawables.TrendUp);
                } else if ("FortyFiveUp".equals(direction)) {
                    trendBitmap.setBitmap(Rez.Drawables.TrendUpRight);
                } else if ("FortyFiveDown".equals(direction)) {
                    trendBitmap.setBitmap(Rez.Drawables.TrendDownRight);
                } else if ("SingleDown".equals(direction) || "DoubleDown".equals(direction)) {
                    trendBitmap.setBitmap(Rez.Drawables.TrendDown);
                } else {
                    trendBitmap.setBitmap(Rez.Drawables.TrendTransparent);
                }
            } else if ("invalid_data".equals(dexError)) {
                dexValueString = "data invalid";
                trendBitmap.setBitmap(Rez.Drawables.TrendTransparent);
            } else if ("no_data".equals(dexError)) {
                dexValueString = "no data";
                trendBitmap.setBitmap(Rez.Drawables.TrendTransparent);

            } else {
                dexValueString = dexError;
                trendBitmap.setBitmap(Rez.Drawables.TrendTransparent);
            }
            Application.getApp().Storage.setValue("dex_values_error", null);

            // set values only if error has changed
            dexValueView.setText(dexValueString);
            dexDetailsView.setText(dexDetailsString);
            self.isFullyInitialized = true;
        }

        // timeView.setColor(getApp().getProperty("ForegroundColor") as Number);
        // timeView.setColor(Graphics.COLOR_WHITE as Number);
        timeView.setText(timeString);
        dateView.setText(dateString);
        

        // var font = WatchUi.loadResource( Rez.Fonts.SunnySpells );
        // dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_DK_RED);
        // dc.drawText(0, 0, font, "test123", Graphics.TEXT_JUSTIFY_CENTER);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
