import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../../../../core/config/api_config.dart';
import '../../../../core/utils/colors/app_color.dart';
import '../../../../core/utils/constants/main_tab.dart';
import '../../../../core/utils/services/injections.dart';
import '../../../auth/presentation/bloc/authentication_bloc.dart';
import '../../../home/presentation/bloc/interview_bloc.dart';
import '../components/bottom_app_bar_item.dart';

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex;
  Timer? _heartbeatTimer;
  String? _token;

  @override
  void initState() {
    currentIndex = widget.navigationShell.currentIndex;
    final user =
        (context.read<AuthenticationBloc>().state as AuthenticatedState)
            .currentUser;

    context.read<InterviewBloc>().add(
          FetchInterviewsEvent(
            candidateId: user.candidateId,
            classId: user.classEntity.id,
          ),
        );
    socket_io.Socket socket = socket_io.io('http://localhost:4000');
    socket.connect();

    // Démarrer le heartbeat pour maintenir l'utilisateur actif
    _startHeartbeat();

    super.initState();
  }

  void _startHeartbeat() async {
    final secureStorage = sl<FlutterSecureStorage>();
    _token = await secureStorage.read(key: 'token');

    // Envoyer un heartbeat toutes les 60 secondes (1 minute)
    _heartbeatTimer =
        Timer.periodic(const Duration(seconds: 60), (timer) async {
      try {
        final state = context.read<AuthenticationBloc>().state;
        if (state is AuthenticatedState && _token != null) {
          // Appeler /api/user pour maintenir l'utilisateur actif
          final response = await http.get(
            Uri.http(ApiConfig.baseUrl, '/api/user'),
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $_token',
            },
          );

          if (response.statusCode == 200) {
            print('✅ Heartbeat envoyé avec succès');
          } else if (response.statusCode == 401) {
            // Token invalide - déconnecter
            print('❌ Token invalide - déconnexion');
            _heartbeatTimer?.cancel();
            if (mounted) {
              context.read<AuthenticationBloc>().add(LogoutEvent());
            }
          }
        }
      } catch (e) {
        print('❌ Erreur heartbeat: $e');
      }
    });
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        elevation: 0.0,
        color: AppColor.white1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BottomAppBarItem(
              onTap: () {
                setState(() => currentIndex = MainTab.home);
                widget.navigationShell.goBranch(MainTab.home);
              },
              icon: 'home',
              isSelected: currentIndex == MainTab.home,
              label: 'Home',
            ),
            BottomAppBarItem(
              onTap: () {
                setState(() => currentIndex = MainTab.result);
                widget.navigationShell.goBranch(MainTab.result);
              },
              icon: 'results',
              isSelected: currentIndex == MainTab.result,
              label: 'Result',
            ),
            BottomAppBarItem(
              onTap: () {
                setState(() => currentIndex = MainTab.setting);
                widget.navigationShell.goBranch(MainTab.setting);
              },
              icon: 'setting',
              isSelected: currentIndex == MainTab.setting,
              label: 'Settings',
            ),
            BottomAppBarItem(
              onTap: () {
                setState(() => currentIndex = MainTab.account);
                widget.navigationShell.goBranch(MainTab.account);
              },
              icon: 'user',
              isSelected: currentIndex == MainTab.account,
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
