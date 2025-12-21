package com.pontoprime.data.remote

import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path

/**
 * Interface Retrofit para comunicação com a API
 */
interface ApiService {

    @POST("punch-record")
    suspend fun createPunchRecord(
        @Body request: PunchRecordRequest
    ): Response<PunchRecordResponse>

    @GET("punch-records/{employeeId}")
    suspend fun getEmployeeRecords(
        @Path("employeeId") employeeId: Int
    ): Response<RecordsListResponse>
}
