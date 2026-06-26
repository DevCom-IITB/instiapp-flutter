package app.insti.flutter;

import android.appwidget.AppWidgetManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * Receives the meal-override broadcast sent by the four meal buttons on the widget.
 *
 * Flow:
 *   Button tap → PendingIntent → MessMenuWidgetReceiver.onReceive()
 *               → MessMenuWidget.updateAppWidget(..., overrideMeal)
 *               → widget re-renders showing the chosen meal, active button highlighted
 *
 * The meal choice is passed as a one-time extra — nothing is persisted to
 * SharedPreferences, so the widget reverts to the time-based meal on the
 * next automatic refresh.
 */
public class MessMenuWidgetReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (!MessMenuWidget.ACTION_MEAL_OVERRIDE.equals(intent.getAction())) return;

        String mealType  = intent.getStringExtra(MessMenuWidget.EXTRA_MEAL_TYPE);
        int appWidgetId  = intent.getIntExtra(
                MessMenuWidget.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID);

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID || mealType == null) return;

        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
        MessMenuWidget.updateAppWidget(context, appWidgetManager, appWidgetId, mealType);
    }
}