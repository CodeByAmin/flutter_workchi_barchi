// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import '../core/di.dart';
// import '../core/constants.dart';
// import '../features/auth/presentation/bloc/auth_bloc.dart';
// import '../features/auth/presentation/pages/phone_input_page.dart';
// import '../features/auth/presentation/pages/otp_verify_page.dart';
// import '../features/auth/presentation/pages/role_selection_page.dart';
// import '../shared_widgets/main_app.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize dependency injection
//   await init();
  
//   runApp(const WorkConnectApp());
// }

// class WorkConnectApp extends StatelessWidget {
//   const WorkConnectApp({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     final GoRouter router = GoRouter(
//       initialLocation: AppRoutes.splash,
//       routes: [
//         GoRoute(
//           path: AppRoutes.splash,
//           builder: (context, state) => const SplashScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.phoneInput,
//           builder: (context, state) => const PhoneInputPage(),
//         ),
//         GoRoute(
//           path: AppRoutes.otpVerify,
//           builder: (context, state) {
//             final phone = state.uri.queryParameters['phone'] ?? '';
//             return OtpVerifyPage(phone: phone);
//           },
//         ),
//         GoRoute(
//           path: AppRoutes.roleSelection,
//           builder: (context, state) => const RoleSelectionPage(),
//         ),
//         GoRoute(
//           path: AppRoutes.workerHome,
//           builder: (context, state) => const WorkerHomePage(),
//         ),
//         GoRoute(
//           path: AppRoutes.employerHome,
//           builder: (context, state) => const EmployerHomePage(),
//         ),
//       ],
//       redirect: (context, state) {
//         // Add authentication redirect logic here
//         return null;
//       },
//     );
    
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AuthBloc>(
//           create: (context) => sl<AuthBloc>(),
//         ),
//       ],
//       child: MaterialApp.router(
//         title: AppStrings.appTitle,
//         theme: ThemeData(
//           primaryColor: AppTheme.primaryColor,
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: AppTheme.primaryColor,
//             primary: AppTheme.primaryColor,
//             secondary: AppTheme.secondaryColor,
//           ),
//           fontFamily: 'Vazir',
//           useMaterial3: true,
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             elevation: 0,
//             centerTitle: true,
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             filled: true,
//             fillColor: Colors.grey[50],
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primaryColor,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),
//         ),
//         routerConfig: router,
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
  
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthStatus();
//   }
  
//   void _checkAuthStatus() async {
//     await Future.delayed(const Duration(seconds: 2));
    
//     final authRepo = sl<AuthRepository>();
    
//     if (authRepo.isLoggedIn()) {
//       final selectedRole = sl<AuthLocalDataSource>().getSelectedRole();
      
//       if (selectedRole == 'worker') {
//         GoRouter.of(context).go(AppRoutes.workerHome);
//       } else if (selectedRole == 'employer') {
//         GoRouter.of(context).go(AppRoutes.employerHome);
//       } else {
//         GoRouter.of(context).go(AppRoutes.roleSelection);
//       }
//     } else {
//       GoRouter.of(context).go(AppRoutes.phoneInput);
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.primaryColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.work_outline,
//                 size: 80,
//                 color: AppTheme.primaryColor,
//               ),
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'WorkConnect',
//               style: TextStyle(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'ایران',
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.white70,
//               ),
//             ),
//             const SizedBox(height: 60),
//             const CircularProgressIndicator(
//               color: Colors.white,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di.dart';
import 'core/constants.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/phone_input_page.dart';
import 'features/auth/presentation/pages/otp_verify_page.dart';
import 'features/auth/presentation/pages/role_selection_page.dart';
import 'shared_widgets/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await init();
  
  runApp(const WorkConnectApp());
}

class WorkConnectApp extends StatelessWidget {
  const WorkConnectApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.phoneInput,
          builder: (context, state) => const PhoneInputPage(),
        ),
        GoRoute(
          path: AppRoutes.otpVerify,
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'] ?? '';
            return OtpVerifyPage(phone: phone);
          },
        ),
        GoRoute(
          path: AppRoutes.roleSelection,
          builder: (context, state) => const RoleSelectionPage(),
        ),
        GoRoute(
          path: AppRoutes.workerHome,
          builder: (context, state) => const WorkerHomePage(),
        ),
        GoRoute(
          path: AppRoutes.employerHome,
          builder: (context, state) => const EmployerHomePage(),
        ),
      ],
      redirect: (context, state) {
        // Add authentication redirect logic here
        return null;
      },
    );
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appTitle,
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isMounted = false;
  
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _checkAuthStatus();
  }
  
  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }
  
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!_isMounted) return;
    
    try {
      // Check if user is logged in
      final authRepo = sl.get<AuthRepository>();
      final localDataSource = sl.get<AuthLocalDataSource>();
      
      final isLoggedIn = authRepo.isLoggedIn();
      
      if (isLoggedIn) {
        final selectedRole = localDataSource.getSelectedRole();
        
        if (selectedRole == 'worker') {
          GoRouter.of(context).go(AppRoutes.workerHome);
        } else if (selectedRole == 'employer') {
          GoRouter.of(context).go(AppRoutes.employerHome);
        } else {
          GoRouter.of(context).go(AppRoutes.roleSelection);
        }
      } else {
        GoRouter.of(context).go(AppRoutes.phoneInput);
      }
    } catch (e) {
      if (_isMounted) {
        GoRouter.of(context).go(AppRoutes.phoneInput);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.work_outline,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'WorkConnect',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ایران',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// Simple interfaces for DI
abstract class AuthRepository {
  bool isLoggedIn();
  // Add other methods as needed
}

abstract class AuthLocalDataSource {
  String? getSelectedRole();
  // Add other methods as needed
}