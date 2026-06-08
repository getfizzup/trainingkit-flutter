package com.fysiki.trainingkit_flutter

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import com.fysiki.trainingkit.fragments.GoFragment
import com.fysiki.trainingkit.interfaces.TrainingKitInterface
import com.fysiki.trainingkit.models.MusicPlaylist
import com.fysiki.trainingkit.states.SaveWorkoutState
import com.fysiki.trainingkit.utils.DeviceIdHelper
import com.fysiki.trainingkit.utils.JWTVerificationException
import com.fysiki.trainingkit.utils.Tracking
import com.google.gson.Gson
import org.json.JSONObject

class ClassicWorkoutActivity : AppCompatActivity(), TrainingKitInterface {
    private var didSave = false

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
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
            val deviceId = DeviceIdHelper.getDeviceId(this)

            val fragment = GoFragment.newInstance(data, config, token, deviceId)

            if (fragment != null) {
                supportFragmentManager.beginTransaction()
                    .replace(view.id, fragment)
                    .commit()

                fragment.viewLifecycleOwnerLiveData.observe(this) { owner ->
                    owner?.lifecycle?.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
                        override fun onCreate(owner: androidx.lifecycle.LifecycleOwner) {
                            fragment.view?.let { fragmentView ->
                                ViewCompat.setOnApplyWindowInsetsListener(fragmentView) { v, insets ->
                                    val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
                                    v.updatePadding(bottom = systemBars.bottom)
                                    insets
                                }
                            }
                        }
                    })
                }
            } else {
                Log.e(TAG, "Failed to create fragment")
                finish()
            }
        } catch (exception: Exception) {
            Log.e(TAG, "Error parsing data", exception)
            finish()
        }
    }

    override fun trackEvent(name: Tracking.Event, properties: Map<Tracking.Property, String>?) {
        val props = properties?.entries?.associate { it.key.toString() to it.value } ?: emptyMap()
        TrainingKitEvents.emitEvent(name.toString(), toJson(props))
    }

    override fun goNextScreen(state: SaveWorkoutState?) {
        finish()
    }

    override fun shouldDisplayCloseButton(): Boolean = true

    override fun closeGoMode(state: SaveWorkoutState?) {
        if (!didSave) {
            TrainingKitEvents.emitQuit()
        }
        finish()
    }

    override fun saveWorkout(state: SaveWorkoutState) {
        didSave = true
        TrainingKitEvents.emitSave(toJson(state))
        finish()
    }

    override fun getApplicationContext(): Context = super.getApplicationContext()

    override fun getAvailablePlaylists(): ArrayList<MusicPlaylist> = arrayListOf()

    override fun onTokenVerificationError(exception: JWTVerificationException) {
        Log.e(TAG, "Token Verification Error", exception)
        finish()
    }

    override fun enableMusicStyle(value: Any?) {}

    override fun disableMusicStyle(value: Any?) {}

    private fun toJson(value: Any?): String =
        try {
            Gson().toJson(value)
        } catch (exception: Exception) {
            "{}"
        }

    companion object {
        private const val TAG = "ClassicWorkoutActivity"
    }
}
