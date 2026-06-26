package app.insti.flutter;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.RemoteViews;

import java.time.OffsetTime;
import java.util.Calendar;
import java.util.List;

import app.insti.api.RetrofitInterface;
import app.insti.api.ServiceGenerator;
import app.insti.api.model.HostelMessMenu;
import app.insti.api.model.MessMenu;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import android.content.SharedPreferences;
import app.insti.flutter.MessMenuRemoteViewsFactory;

/**
 * Implementation of App Widget functionality.
 * Supports meal override via MessMenuWidgetReceiver (one-time, no saving).
 */
public class MessMenuWidget extends AppWidgetProvider {

    // Action sent by the meal buttons via BroadcastReceiver
    public static final String ACTION_MEAL_OVERRIDE = "app.insti.flutter.ACTION_MEAL_OVERRIDE";
    public static final String EXTRA_MEAL_TYPE      = "extra_meal_type";
    public static final String EXTRA_APPWIDGET_ID   = "extra_appwidget_id";

    // Meal type constants (mirrors the logic in displayMessMenu)
    public static final String MEAL_BREAKFAST = "Breakfast";
    public static final String MEAL_LUNCH     = "Lunch";
    public static final String MEAL_SNACKS    = "Snacks";
    public static final String MEAL_DINNER    = "Dinner";
    
    private static String currentMenu = "";
    private static RemoteViews views;
    private static List<HostelMessMenu> instituteMessMenu;

    // -----------------------------------------------------------------------
    // Core update — called on normal refresh AND after a meal override
    // overrideMeal: if non-null, show this meal instead of the time-based one
    // -----------------------------------------------------------------------
    public static void updateAppWidget(Context context,
                                       AppWidgetManager appWidgetManager,
                                       int appWidgetId,
                                       String overrideMeal) {

        views = new RemoteViews(context.getPackageName(), R.layout.mess_menu_widget);

        // Attach meal-button PendingIntents
        attachMealButtonIntents(context, appWidgetId);

        // Attach the widget-tap deep-link
        Intent openIntent = new Intent(context, MainActivity.class);
        openIntent.setAction(Intent.ACTION_VIEW);
        openIntent.setData(Uri.parse("https://www.insti.app/mess/"));
        PendingIntent openPending = PendingIntent.getActivity(
                context, 0, openIntent, PendingIntent.FLAG_MUTABLE);
        views.setOnClickPendingIntent(R.id.mess_menu_widget, openPending);

        ServiceGenerator serviceGenerator = new ServiceGenerator(context);
        RetrofitInterface retrofitInterface = serviceGenerator.getRetrofitInterface();
        retrofitInterface.getInstituteMessMenu(1).enqueue(new Callback<List<HostelMessMenu>>() {

            @Override
            public void onResponse(Call<List<HostelMessMenu>> call,
                                   Response<List<HostelMessMenu>> response) {
                if (response.isSuccessful()) {
                    instituteMessMenu = response.body();
                    CharSequence hostel = MessMenuWidgetWithHostelConfigureActivity
                        .loadTitlePref(context, appWidgetId);

                    // Header title
                    views.setTextViewText(
                            R.id.header_title,
                            hostel + " Mess Menu"
                    );

                    displayMenu(hostel, overrideMeal);

                    SharedPreferences prefs = context.getSharedPreferences(
                            MessMenuRemoteViewsFactory.PREFS_NAME, Context.MODE_PRIVATE);
                    prefs.edit()
                        .putString(MessMenuRemoteViewsFactory.KEY_MENU_PREFIX + appWidgetId, currentMenu)
                        .apply();

                    Intent serviceIntent = new Intent(context, MessMenuRemoteViewsService.class);
                    serviceIntent.putExtra(MessMenuWidget.EXTRA_APPWIDGET_ID, appWidgetId);
                    views.setRemoteAdapter(R.id.meal_list_view, serviceIntent);

                    appWidgetManager.updateAppWidget(appWidgetId, views);
                    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.meal_list_view);
                }
            }

            @Override
            public void onFailure(Call<List<HostelMessMenu>> call, Throwable t) {
                // Network error — widget keeps its last-rendered state
            }
        });
    }

    // Convenience overload used by the original onUpdate path (no override)
    public static void updateAppWidget(Context context,
                                       AppWidgetManager appWidgetManager,
                                       int appWidgetId) {
        updateAppWidget(context, appWidgetManager, appWidgetId, null);
    }

    // -----------------------------------------------------------------------
    // Attach a PendingIntent to each of the four meal buttons.
    // Each intent is a broadcast to MessMenuWidgetReceiver carrying the
    // meal name and widget id — no SharedPreferences involved.
    // -----------------------------------------------------------------------
    private static void attachMealButtonIntents(Context context, int appWidgetId) {
        String[] meals    = {MEAL_BREAKFAST, MEAL_LUNCH, MEAL_SNACKS, MEAL_DINNER};
        int[]    buttonIds = {R.id.btn_breakfast, R.id.btn_lunch,
                              R.id.btn_snacks,    R.id.btn_dinner};

        for (int i = 0; i < meals.length; i++) {
            Intent intent = new Intent(context, MessMenuWidgetReceiver.class);
            intent.setAction(ACTION_MEAL_OVERRIDE);
            intent.putExtra(EXTRA_MEAL_TYPE, meals[i]);
            intent.putExtra(EXTRA_APPWIDGET_ID, appWidgetId);
            // Unique request code per meal+widget so PendingIntents are distinct
            int requestCode = appWidgetId * 10 + i;
            PendingIntent pi = PendingIntent.getBroadcast(
                    context, requestCode, intent, PendingIntent.FLAG_MUTABLE |
                    PendingIntent.FLAG_UPDATE_CURRENT);
            views.setOnClickPendingIntent(buttonIds[i], pi);
        }
    }

    // -----------------------------------------------------------------------
    // Display helpers
    // -----------------------------------------------------------------------
    private static void displayMenu(CharSequence hostel, String overrideMeal) {
        HostelMessMenu hostelMessMenu = findMessMenu(instituteMessMenu, hostel);
        if (hostelMessMenu != null)
            displayMessMenu(hostelMessMenu, overrideMeal);
    }

    private static void displayMessMenu(HostelMessMenu hostelMessMenu, String overrideMeal) {
        MessMenu todaysMenu = hostelMessMenu.getSortedMessMenus().get(0);
        MessMenu tomsMenu   = hostelMessMenu.getSortedMessMenus().get(1);

        int day = todaysMenu.getDay();

        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        int hourOfDay = OffsetTime.now().getHour();

        // Determine time-based meal (used when no override is active)
        String timeMeal;
        if (hourOfDay >= 22 || hourOfDay < 10) {
            timeMeal = MEAL_BREAKFAST;
        } else if (hourOfDay < 14) {
            timeMeal = MEAL_LUNCH;
        } else if (hourOfDay < 18) {
            timeMeal = MEAL_SNACKS;
        } else {
            timeMeal = MEAL_DINNER;
        }

        // Resolve which meal to actually display
        String activeMeal = (overrideMeal != null) ? overrideMeal : timeMeal;

        String mealType;
        String mealTime;
        String menu;

        switch (activeMeal) {
            case MEAL_BREAKFAST:
                mealType = MEAL_BREAKFAST;
                if (hourOfDay >= 22) {
                    menu = tomsMenu.getBreakfast();
                    day  = tomsMenu.getDay();
                } else {
                    menu = todaysMenu.getBreakfast();
                }
                mealTime = (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY)
                        ? "8am to 10am" : "7:30am to 9:30am";
                break;
            case MEAL_LUNCH:
                mealType = MEAL_LUNCH;
                menu     = todaysMenu.getLunch();
                mealTime = "12noon to 2pm";
                break;
            case MEAL_SNACKS:
                mealType = MEAL_SNACKS;
                menu     = todaysMenu.getSnacks();
                mealTime = "4:30pm to 6:15pm";
                break;
            default: // MEAL_DINNER
                mealType = MEAL_DINNER;
                menu     = todaysMenu.getDinner();
                mealTime = "8pm to 10pm";
                break;
        }
        
        currentMenu = menu;
        views.setTextViewText(R.id.meal_name_text_view, mealType);

        // Highlight the active meal button
        highlightActiveButton(activeMeal);
    }

    // Sets the active button to a highlighted background; all others to normal.
    private static void highlightActiveButton(String activeMeal) {
    int[] buttonIds = {
            R.id.btn_breakfast,
            R.id.btn_lunch,
            R.id.btn_snacks,
            R.id.btn_dinner
    };

    String[] meals = {
            MEAL_BREAKFAST,
            MEAL_LUNCH,
            MEAL_SNACKS,
            MEAL_DINNER
    };

    final int normalTextColor = 0xCC0F1620;
    final int activeTextColor = 0xFF306FDC;

    for (int i = 0; i < buttonIds.length; i++) {

        boolean active = meals[i].equals(activeMeal);

        views.setInt(
                buttonIds[i],
                "setBackgroundResource",
                active
                        ? R.drawable.meal_button_active_background
                        : R.drawable.meal_button_background
        );

        views.setInt(
                buttonIds[i],
                "setTextColor",
                active ? activeTextColor : normalTextColor
        );
    }
}

    private static HostelMessMenu findMessMenu(List<HostelMessMenu> hostelMessMenus,
                                               CharSequence hostel) {
        for (HostelMessMenu h : hostelMessMenus) {
            if (h.getShortName().equals(hostel)) return h;
        }
        return null;
    }

    public static String generateDayString(int day) {
        switch (day) {
            case 1: return "Monday";
            case 2: return "Tuesday";
            case 3: return "Wednesday";
            case 4: return "Thursday";
            case 5: return "Friday";
            case 6: return "Saturday";
            case 7: return "Sunday";
            default: throw new IndexOutOfBoundsException("DayIndexOutOfBounds: " + day);
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager,
                         int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }
}