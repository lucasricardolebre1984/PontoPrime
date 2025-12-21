package com.pontoprime.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Entidade Room para armazenamento local de registros de ponto
 */
@Entity(tableName = "punch_records")
data class PunchRecord(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val employeeId: Int,
    val timestamp: String,
    val latitude: Double,
    val longitude: Double,
    val isSynced: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)
