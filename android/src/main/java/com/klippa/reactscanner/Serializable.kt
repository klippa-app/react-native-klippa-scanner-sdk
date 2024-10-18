package com.klippa.reactscanner

import android.content.Intent
import android.os.Build
import java.io.Serializable

internal inline fun <reified T : Serializable> Intent.serializable(key: String): T? =
    when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> getSerializableExtra(key, T::class.java)
        else -> {
            @Suppress("DEPRECATION")
            getSerializableExtra(key) as? T
        }
    }
