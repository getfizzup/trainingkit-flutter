package com.fysiki.trainingkit_flutter

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.mediarouter.app.MediaRouteButton
import com.fysiki.trainingkit.fragments.WorkoutVideoFragment
import com.fysiki.trainingkit.interfaces.WorkoutVideoKitInterface
import com.fysiki.trainingkit.states.SaveWorkoutState
import com.fysiki.trainingkit.utils.JWTVerificationException
import com.fysiki.trainingkit.utils.TrackingData
import org.jdeferred.Promise
import org.jdeferred.impl.DeferredObject
import org.json.JSONObject

class VideoWorkoutActivity : AppCompatActivity(), WorkoutVideoKitInterface {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val view = android.widget.FrameLayout(this)
        view.id = View.generateViewId()
        setContentView(view)

        val jsonString = intent.getStringExtra("jsonString")
        val token = intent.getStringExtra("token")

        if (jsonString == null || token == null) {
            Log.e(TAG, "Missing data or token")
            finish()
            return
        }

        try {
            val data = JSONObject(jsonString)
            val config = JSONObject()
            val fragment = WorkoutVideoFragment.newInstance(data, config, token, true)

            if (fragment != null) {
                supportFragmentManager.beginTransaction()
                    .replace(view.id, fragment)
                    .commit()
            } else {
                Log.e(TAG, "Failed to create fragment")
                finish()
            }
        } catch (exception: Exception) {
            Log.e(TAG, "Error parsing data", exception)
            finish()
        }
    }

    override fun saveWorkout(saveState: SaveWorkoutState): Promise<*, *, *> {
        Log.d(TAG, "Save Video Workout")
        val deferred = DeferredObject<Any?, Any?, Any?>()
        deferred.resolve(null)
        finish()
        return deferred.promise()
    }

    override fun goToNextScreen() {
        finish()
    }

    override fun logError(message: String, data: HashMap<String, Any>) {
        Log.e(TAG, "Error: $message, $data")
    }

    override fun reviseExercise() {
        Log.d(TAG, "Revise Exercise")
    }

    override fun setupChromecastButton(castButton: MediaRouteButton) {}

    override fun trackEvent(data: TrackingData) {
        Log.d(TAG, "Track Event: $data")
    }

    override fun onTokenVerificationError(exception: JWTVerificationException) {
        Log.e(TAG, "Token Verification Error", exception)
        finish()
    }

    override fun isAdmin(): Boolean = false

    companion object {
        private const val TAG = "VideoWorkoutActivity"
    }
}
