package com.pontoprime.ui.main

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.pontoprime.data.local.AppDatabase
import com.pontoprime.data.remote.RetrofitClient
import com.pontoprime.data.repository.PunchRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class MainUiState(
    val isLoading: Boolean = false,
    val showSuccessDialog: Boolean = false,
    val errorMessage: String? = null,
    val showBiometricPrompt: Boolean = false
)

class MainViewModel(
    private val employeeId: Int,
    private val repository: PunchRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(MainUiState())
    val uiState: StateFlow<MainUiState> = _uiState.asStateFlow()

    fun onRegisterPunchClick() {
        // MVP: Mostra "biometria" simulada e registra direto
        _uiState.value = _uiState.value.copy(showBiometricPrompt = true)
        registerPunch()
    }

    private fun registerPunch() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)

            try {
                // MVP: Localização mockada (São Paulo)
                val latitude = -23.5505
                val longitude = -46.6333

                val result = repository.registerPunch(
                    employeeId = employeeId,
                    latitude = latitude,
                    longitude = longitude
                )

                if (result.isSuccess) {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        showSuccessDialog = true,
                        showBiometricPrompt = false
                    )
                } else {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = "Erro ao registrar ponto",
                        showBiometricPrompt = false
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Erro: ${e.message}",
                    showBiometricPrompt = false
                )
            }
        }
    }

    fun dismissSuccessDialog() {
        _uiState.value = _uiState.value.copy(showSuccessDialog = false)
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    class Factory(
        private val employeeId: Int
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            val application = try {
                // Obter application do contexto
                Class.forName("android.app.ActivityThread")
                    .getMethod("currentApplication")
                    .invoke(null) as Application
            } catch (e: Exception) {
                throw IllegalStateException("Cannot create ViewModel without Application")
            }

            val database = AppDatabase.getDatabase(application)
            val repository = PunchRepository(database, RetrofitClient.apiService)

            return MainViewModel(employeeId, repository) as T
        }
    }
}
