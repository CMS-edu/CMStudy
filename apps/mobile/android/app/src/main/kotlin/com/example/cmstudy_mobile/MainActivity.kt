package com.example.cmstudy_mobile

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private var reminderChannel: MethodChannel? = null
    private var pendingLaunchAction: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        pendingLaunchAction = extractLaunchAction(intent)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        reminderChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cmstudy/reminders",
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleDaily" -> {
                        val args = call.arguments as? Map<*, *>
                        result.success(args?.let { scheduleDailyReminder(it) } ?: false)
                    }
                    "consumeLaunchAction" -> {
                        val action = pendingLaunchAction
                        pendingLaunchAction = null
                        result.success(action)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val action = extractLaunchAction(intent)
        if (action != null) {
            pendingLaunchAction = action
            reminderChannel?.invokeMethod("launchAction", action)
        }
    }

    private fun scheduleDailyReminder(args: Map<*, *>): Boolean {
        requestNotificationPermissionIfNeeded()
        val id = (args["id"] as? Number)?.toInt() ?: return false
        val title = args["title"]?.toString() ?: "CMStudy"
        val body = args["body"]?.toString() ?: "공부 미션 시간이 시작됐습니다."
        val hour = ((args["hour"] as? Number)?.toInt() ?: 0).coerceIn(0, 23)
        val minute = ((args["minute"] as? Number)?.toInt() ?: 0).coerceIn(0, 59)

        val intent = Intent(this, ReminderReceiver::class.java).apply {
            putExtra("notification_id", id)
            putExtra("title", title)
            putExtra("body", body)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val triggerTime = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }.timeInMillis

        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            triggerTime,
            AlarmManager.INTERVAL_DAY,
            pendingIntent,
        )
        return true
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 2301)
    }

    private fun extractLaunchAction(intent: Intent?): String? {
        return intent?.getStringExtra("cmstudy_action")
    }
}
