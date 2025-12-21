package com.pontoprime.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.pontoprime.ui.history.HistoryScreen
import com.pontoprime.ui.login.LoginScreen
import com.pontoprime.ui.main.MainScreen

/**
 * Rotas de navegação
 */
sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Main : Screen("main/{employeeId}") {
        fun createRoute(employeeId: Int) = "main/$employeeId"
    }
    object History : Screen("history/{employeeId}") {
        fun createRoute(employeeId: Int) = "history/$employeeId"
    }
}

/**
 * Grafo de navegação da aplicação
 */
@Composable
fun PontoPrimeNavGraph(
    navController: NavHostController,
    startDestination: String = Screen.Login.route
) {
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        // Tela de Login
        composable(Screen.Login.route) {
            LoginScreen(
                onLoginSuccess = { employeeId ->
                    navController.navigate(Screen.Main.createRoute(employeeId)) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }

        // Tela Principal
        composable(
            route = Screen.Main.route,
            arguments = listOf(
                navArgument("employeeId") { type = NavType.IntType }
            )
        ) { backStackEntry ->
            val employeeId = backStackEntry.arguments?.getInt("employeeId") ?: 0
            MainScreen(
                employeeId = employeeId,
                onNavigateToHistory = {
                    navController.navigate(Screen.History.createRoute(employeeId))
                },
                onLogout = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }

        // Tela de Histórico
        composable(
            route = Screen.History.route,
            arguments = listOf(
                navArgument("employeeId") { type = NavType.IntType }
            )
        ) { backStackEntry ->
            val employeeId = backStackEntry.arguments?.getInt("employeeId") ?: 0
            HistoryScreen(
                employeeId = employeeId,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
