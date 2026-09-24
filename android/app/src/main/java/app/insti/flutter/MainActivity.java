package app.insti.flutter;

import android.view.WindowManager;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
	private static final String CHANNEL_NAME = "instiapp/profile_screen_protection";
	private Float previousScreenBrightness;

	@Override
	public void configureFlutterEngine(FlutterEngine flutterEngine) {
		super.configureFlutterEngine(flutterEngine);

		new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME)
				.setMethodCallHandler((call, result) -> {
					switch (call.method) {
						case "enable":
							if (previousScreenBrightness == null) {
								previousScreenBrightness = getWindow().getAttributes().screenBrightness;
							}
							getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
							WindowManager.LayoutParams enabledAttributes = getWindow().getAttributes();
							enabledAttributes.screenBrightness = 1.0f;
							getWindow().setAttributes(enabledAttributes);
							result.success(null);
							break;
						case "disable":
							getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
							if (previousScreenBrightness != null) {
								WindowManager.LayoutParams restoredAttributes = getWindow().getAttributes();
								restoredAttributes.screenBrightness = previousScreenBrightness;
								getWindow().setAttributes(restoredAttributes);
							}
							previousScreenBrightness = null;
							result.success(null);
							break;
						default:
							result.notImplemented();
							break;
					}
				});
	}
}
