import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/colors/app_color.dart';
import '../../../../core/utils/constants/routes.dart';
import '../../../../shared/components/buttons/gradient_button.dart';
import '../../../auth/presentation/bloc/authentication_bloc.dart';
import '../../domain/entity/interview_entity.dart';
import '../bloc/interview_bloc.dart';
import '../clip/header_painter.dart';

class Header extends StatelessWidget {
  final InterviewEntity? interview;

  const Header({
    super.key,
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          CustomPaint(
            painter: HeaderPainter(),
            size: Size.fromHeight(MediaQuery.sizeOf(context).height * 0.4),
          ),
          Positioned(
            top: 100,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.95,
                    height: 300.h,
                    decoration: BoxDecoration(
                      color: AppColor.blue3,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          spreadRadius: 3,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: SvgPicture.asset(
                                    'assets/images/circle.svg',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/Stars.png',
                                      width: 51.w,
                                      height: 51.w,
                                    ),
                                    const Gap(20),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '150\n',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary),
                                          ),
                                          TextSpan(
                                            text: 'Total points',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: SvgPicture.asset(
                                  'assets/images/circle.svg',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Today’s Quiz on',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        AppColor.purple4,
                                        AppColor.purple3,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(
                                      Rect.fromLTWH(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    ),
                                    child: Text(
                                      interview!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  Text(
                                    '${interview?.subject.questions.length} questions',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColor.purple3,
                                        ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: 1,
                                    child: GradientButton(
                                      onPressed: () => interview!.isCompleted
                                          ? _onTapped(context)
                                          : context.push(
                                              Routes.quiz,
                                              extra: interview,
                                            ),
                                      colors: const [
                                        AppColor.purple4,
                                        AppColor.purple3,
                                      ],
                                      borderRadius: 24,
                                      child: Text(
                                        'PLAY QUIZ NOW',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapped(BuildContext context) {
    if (interview != null) {
      final candidateId =
          (context.read<AuthenticationBloc>().state as AuthenticatedState)
              .currentUser
              .candidateId;
      context.read<InterviewBloc>().add(
            FetchInterviewCorrectionEvent(
              candidateId: candidateId,
              interviewId: interview!.id,
            ),
          );
      context.push('${Routes.userAnswer}?interview=${interview!.id}');
    }
  }
}
