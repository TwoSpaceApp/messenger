package com.synapse.twospace

import android.app.Service
import android.app.Notification
import android.app.NotificationManager
import android.app.NotificationChannel
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.content.Context

/**
 * Foreground service for background message listening.
 * Keeps the app running in the background with a persistent notification.
 * This allows the Aegis protocol client to receive messages continuously.
 */
class NotificationForegroundService : Service() {
    companion object {
        private const val NOTIFICATION_CHANNEL_ID = "twospace_service"
        private const val NOTIFICATION_ID = 999
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Create notification channel for Android 8+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "TwoSpace Service Status",
                NotificationManager.IMPORTANCE_MIN
            ).apply {
                description = "Persistent notification for background message listening"
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
            }
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
        }

        // Build persistent notification
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("TwoSpace")
            .setContentText("Connected")
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Use system icon as fallback
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setOngoing(true)
            .setAutoCancel(false)
            .build()

        // Start foreground service
        startForeground(NOTIFICATION_ID, notification)

        // Service sticky: restart if killed by system
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopForeground(STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }
}
