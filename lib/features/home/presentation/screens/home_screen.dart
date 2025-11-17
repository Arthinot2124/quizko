import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/constants/routes.dart';
import '../../../auth/presentation/bloc/authentication_bloc.dart';
import '../bloc/interview_bloc.dart' as interview_bloc;
import '../bloc/interview_bloc.dart';
import '../components/header.dart';
import '../components/quiz.dart';
import 'no_quizzes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        // Vérifier que l'utilisateur est bien authentifié
        if (authState is! AuthenticatedState) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentUser = authState.currentUser;

        return BlocBuilder<InterviewBloc, InterviewState>(
            builder: (context, state) {
      if (state is interview_bloc.LoadingState ||
          state is interview_bloc.InitialState) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is interview_bloc.InterviewsLoaded) {
        if (state.interviews.isEmpty) {
          return const NoQuizzesScreen();
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: currentUser.gender == 'masculine'
                    ? const AssetImage('assets/images/male.jpg')
                    : const AssetImage('assets/images/female.jpg'),
                backgroundColor: Colors.red,
                radius: 15.0,
              ),
            ),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Hi, ${currentUser.fullName}\n',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  TextSpan(
                    text: currentUser.registrationNumber,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
            actions: [
              Image.asset('assets/logo/eni.png'),
              const Gap(10),
            ],
          ),
          body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Column(
              children: [
                Expanded(
                    child: Header(
                  interview: state.interviews.firstOrNull,
                )),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Discover Quiz',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.push(Routes.seeAllQuiz),
                              child: Row(
                                children: [
                                  Text(
                                    'See all',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                  const Gap(10),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18.sp,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(0),
                            itemCount: state.interviews.length > 3
                                ? 5
                                : state.interviews.length,
                            separatorBuilder: (context, index) => const Gap(10),
                            itemBuilder: (context, index) => Quiz(
                              interview: state.interviews[index],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
        });
      },
    );
  }
}
