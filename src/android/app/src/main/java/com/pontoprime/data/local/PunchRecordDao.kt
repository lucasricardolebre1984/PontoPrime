package com.pontoprime.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

/**
 * DAO para operações de banco de dados dos registros de ponto
 */
@Dao
interface PunchRecordDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(record: PunchRecord): Long

    @Update
    suspend fun update(record: PunchRecord)

    @Query("SELECT * FROM punch_records WHERE employeeId = :employeeId ORDER BY createdAt DESC")
    fun getRecordsByEmployee(employeeId: Int): Flow<List<PunchRecord>>

    @Query("SELECT * FROM punch_records WHERE isSynced = 0")
    suspend fun getUnsyncedRecords(): List<PunchRecord>

    @Query("SELECT * FROM punch_records ORDER BY createdAt DESC")
    fun getAllRecords(): Flow<List<PunchRecord>>

    @Query("DELETE FROM punch_records")
    suspend fun deleteAll()
}
