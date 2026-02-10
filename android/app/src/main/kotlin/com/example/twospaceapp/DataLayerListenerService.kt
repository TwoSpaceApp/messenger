package com.example.two_space_app

import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import android.util.Log

class DataLayerListenerService : WearableListenerService() {

    override fun onMessageReceived(messageEvent: MessageEvent) {
        super.onMessageReceived(messageEvent)

        when (messageEvent.path) {
            "new_message" -> {
                val data = String(messageEvent.data)
                Log.d("WatchService", "New message from phone: $data")
                // Here you would build and display a notification on the watch
            }
            "incoming_call" -> {
                val data = String(messageEvent.data)
                Log.d("WatchService", "Incoming call from: $data")
                // Here you would build and display a full-screen incoming call notification
            }
            "hangup_call" -> {
                Log.d("WatchService", "Hangup call from phone")
                // Here you would dismiss any call-related notifications
            }
        }
    }
}
