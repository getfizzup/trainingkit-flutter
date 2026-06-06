package com.fysiki.trainingkit_flutter

import android.content.Context
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider

class CastOptionsProvider : OptionsProvider {
    override fun getCastOptions(context: Context): CastOptions {
        val receiverApplicationId = BuildConfig.CHROMECAST_RECEIVER_APPLICATION_ID.trim()
        val builder = CastOptions.Builder()

        if (receiverApplicationId.isNotEmpty()) {
            builder.setReceiverApplicationId(receiverApplicationId)
        }

        return builder.build()
    }

    override fun getAdditionalSessionProviders(context: Context): List<SessionProvider>? {
        return null
    }
}
