package com.example.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager

class MainActivity: FlutterActivity() {
	private val CHANNEL = "screen_protector"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"enableSecure" -> {
					runOnUiThread {
						window.setFlags(
							WindowManager.LayoutParams.FLAG_SECURE,
							WindowManager.LayoutParams.FLAG_SECURE
						)
					}
					result.success(null)
				}
				"disableSecure" -> {
					runOnUiThread {
						window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
					}
					result.success(null)
				}
				else -> result.notImplemented()
			}
		}
	}
}
