package com.pontoprime.data.remote

import com.google.gson.annotations.SerializedName

/**
 * Request para registrar ponto
 */
data class PunchRecordRequest(
    @SerializedName("employee_id")
    val employeeId: Int,
    val timestamp: String,
    val latitude: Double,
    val longitude: Double
)

/**
 * Response do registro de ponto
 */
data class PunchRecordResponse(
    val success: Boolean,
    val message: String,
    @SerializedName("record_id")
    val recordId: Int?
)

/**
 * Response para lista de registros
 */
data class RecordsListResponse(
    @SerializedName("employee_id")
    val employeeId: Int,
    val records: List<RecordItem>,
    val total: Int
)

data class RecordItem(
    val id: Int,
    @SerializedName("employee_id")
    val employeeId: Int,
    val timestamp: String,
    val latitude: Double,
    val longitude: Double
)
