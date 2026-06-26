package app.insti.flutter;

import android.content.Intent;
import android.widget.RemoteViewsService;

public class MessMenuRemoteViewsService extends RemoteViewsService {

    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent) {
        return new MessMenuRemoteViewsFactory(this.getApplicationContext(), intent);
    }
}