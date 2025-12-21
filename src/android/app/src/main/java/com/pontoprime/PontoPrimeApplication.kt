package com.pontoprime

import android.app.Application
import com.pontoprime.data.local.AppDatabase

/**
 * Application class - Inicializa componentes globais
 */
class PontoPrimeApplication : Application() {

    // Banco de dados singleton
    val database: AppDatabase by lazy { AppDatabase.getDatabase(this) }

    override fun onCreate() {
        super.onCreate()
        // Inicializações globais futuras podem ser adicionadas aqui
    }
}
