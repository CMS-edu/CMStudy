package com.example.cmstudy_mobile

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra("notification_id", 1001)
        val title = intent.getStringExtra("title") ?: "CMStudy"
        val body = intent.getStringExtra("body") ?: "공부 미션 시간이 시작됐습니다."
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Study reminders",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "CMStudy time mission reminders"
            }
            manager.createNotificationChannel(channel)
        }

        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("cmstudy_action", "start_study")
            } ?: Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("cmstudy_action", "start_study")
            }
        val contentIntent = PendingIntent.getActivity(
            context,
            notificationId,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val notification = builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .setCategory(Notification.CATEGORY_REMINDER)
            .setPriority(Notification.PRIORITY_HIGH)
            .build()

        try {
            manager.notify(notificationId, notification)
        } catch (_: SecurityException) {
            // Android 13+ users can deny notifications; the mission itself still works.
        }
    }

    companion object {
        private const val CHANNEL_ID = "cmstudy_time_missions"
    }
}
