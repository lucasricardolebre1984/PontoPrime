package com.pontoprime.data.repository

import com.pontoprime.data.local.AppDatabase
import com.pontoprime.data.local.PunchRecord
import com.pontoprime.data.remote.ApiService
import com.pontoprime.data.remote.PunchRecordRequest
import kotlinx.coroutines.flow.Flow
import java.text.SimpleDateFormat
import java.util.*

/**
 * Repository para gerenciar operações de punch records
 * Camada de abstração entre ViewModel e Data Sources (Room + Retrofit)
 */
class PunchRepository(
    private val database: AppDatabase,
    private val apiService: ApiService
) {
    private val dao = database.punchRecordDao()

    /**
     * Registra um ponto (salva local e tenta enviar para API)
     */
    suspend fun registerPunch(
        employeeId: Int,
        latitude: Double,
        longitude: Double
    ): Result<Long> {
        return try {
            val timestamp = getCurrentTimestamp()

            // 1. Salvar localmente primeiro
            val record = PunchRecord(
                employeeId = employeeId,
                timestamp = timestamp,
                latitude = latitude,
                longitude = longitude,
                isSynced = false
            )
            val recordId = dao.insert(record)

            // 2. Tentar enviar para API
            try {
                val request = PunchRecordRequest(
                    employeeId = employeeId,
                    timestamp = timestamp,
                    latitude = latitude,
                    longitude = longitude
                )
                val response = apiService.createPunchRecord(request)

                if (response.isSuccessful) {
                    // Marcar como sincronizado
                    dao.update(record.copy(id = recordId, isSynced = true))
                }
            } catch (e: Exception) {
                // Se falhar API, não problema - ficará como não sincronizado
                // e tentará sincronizar depois
            }

            Result.success(recordId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Obtém registros de um funcionário (do banco local)
     */
    fun getEmployeeRecords(employeeId: Int): Flow<List<PunchRecord>> {
        return dao.getRecordsByEmployee(employeeId)
    }

    /**
     * Sincroniza registros pendentes
     */
    suspend fun syncPendingRecords() {
        try {
            val unsyncedRecords = dao.getUnsyncedRecords()
            unsyncedRecords.forEach { record ->
                try {
                    val request = PunchRecordRequest(
                        employeeId = record.employeeId,
                        timestamp = record.timestamp,
                        latitude = record.latitude,
                        longitude = record.longitude
                    )
                    val response = apiService.createPunchRecord(request)

                    if (response.isSuccessful) {
                        dao.update(record.copy(isSynced = true))
                    }
                } catch (e: Exception) {
                    // Continua para o próximo registro
                }
            }
        } catch (e: Exception) {
            // Silenciosamente falha - tentará novamente depois
        }
    }

    private fun getCurrentTimestamp(): String {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
        return dateFormat.format(Date())
    }
}
