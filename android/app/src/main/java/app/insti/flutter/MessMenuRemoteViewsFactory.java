package app.insti.flutter;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import java.util.ArrayList;
import java.util.List;

public class MessMenuRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory {

    public static final String PREFS_NAME     = "MessMenuWidgetPrefs";
    public static final String KEY_MENU_PREFIX = "menu_";  // + appWidgetId

    private final Context context;
    private final int appWidgetId;
    private final List<String> menuItems = new ArrayList<>();

    public MessMenuRemoteViewsFactory(Context context, Intent intent) {
        this.context = context;
        this.appWidgetId = intent.getIntExtra(
                MessMenuWidget.EXTRA_APPWIDGET_ID, 0);
    }

    // Called once when the factory is first created
    @Override
    public void onCreate() {
        loadItems();
    }

    // Called when notifyAppWidgetViewDataChanged() is triggered
    @Override
    public void onDataSetChanged() {
        loadItems();
    }

    @Override
    public void onDestroy() {
        menuItems.clear();
    }

    @Override
    public int getCount() {
        return menuItems.size();
    }

    @Override
    public RemoteViews getViewAt(int position) {
        RemoteViews rv = new RemoteViews(
                context.getPackageName(), R.layout.meal_list_item);
        rv.setTextViewText(R.id.meal_list_item_text, menuItems.get(position));
        return rv;
    }

    // Shown while a real row is loading
    @Override
    public RemoteViews getLoadingView() {
        return null; // use default
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    // -----------------------------------------------------------------------
    // Read the menu string saved by MessMenuWidget and split it into items
    // -----------------------------------------------------------------------
    private void loadItems() {
        menuItems.clear();

        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        String raw = prefs.getString(KEY_MENU_PREFIX + appWidgetId, "");

        if (raw == null || raw.trim().isEmpty()) return;

        // Menu items are separated by " • " — split and trim each one
        String[] parts = raw.split("•");
        for (String part : parts) {
            String item = part.trim();
            if (!item.isEmpty()) {
                menuItems.add("• " + item);
            }
        }
    }
}