package com.pontoprime.ui.history

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.pontoprime.data.local.AppDatabase
import com.pontoprime.data.local.PunchRecord
import com.pontoprime.data.remote.RetrofitClient
import com.pontoprime.data.repository.PunchRepository
import kotlinx.coroutines.flow.Flow

class HistoryViewModel(
    private val employeeId: Int,
    private val repository: PunchRepository
) : ViewModel() {

    val records: Flow<List<PunchRecord>> = repository.getEmployeeRecords(employeeId)

    class Factory(
        private val employeeId: Int
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            val application = try {
                Class.forName("android.app.ActivityThread")
                    .getMethod("currentApplication")
                    .invoke(null) as Application
            } catch (e: Exception) {
                throw IllegalStateException("Cannot create ViewModel without Application")
            }

            val database = AppDatabase.getDatabase(application)
            val repository = PunchRepository(database, RetrofitClient.apiService)

            return HistoryViewModel(employeeId, repository) as T
        }
    }
}
