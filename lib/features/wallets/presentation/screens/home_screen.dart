import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/animations/animations.dart';
import 'package:wallet_split/core/helpers/currency_formatter.dart';
import 'package:wallet_split/core/helpers/extensions.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/core/routes/routes.dart';
import 'package:wallet_split/features/wallets/domain/entities/wallet.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallets_state.dart';
import 'package:wallet_split/features/wallets/presentation/widgets/add_wallet_sheet.dart';
import 'package:wallet_split/features/wallets/presentation/widgets/transaction_tile.dart';
import 'package:wallet_split/features/wallets/presentation/widgets/wallet_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletsCubit>().watchAll();
  }

  void _openWallet(Wallet wallet) {
    context.pushNamed(Routes.walletDetail, arguments: wallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr()),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'settings.title'.tr(),
          ),
        ],
      ),
      body: BlocBuilder<WalletsCubit, WalletsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => context.read<WalletsCubit>().watchAll(),
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                _TotalBalanceCard(totalBalance: state.totalBalance),
                verticalSpace(28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'home.wallets_section'.tr(),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    IconButton(
                      onPressed: () => showAddWalletSheet(context),
                      icon: Icon(
                        Icons.add_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 26.sp,
                      ),
                      tooltip: 'wallets.add_wallet_title'.tr(),
                    ),
                  ],
                ),
                verticalSpace(8),
                if (state.wallets.isEmpty && !state.isLoading)
                  _EmptyHint(text: 'wallets.empty'.tr())
                else
                  ...AnimationBuilder.staggerColumn(
                    children: state.wallets
                        .map(
                          (wallet) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: WalletCard(
                              wallet: wallet,
                              onTap: () => _openWallet(wallet),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                verticalSpace(20),
                Text(
                  'home.recent_activity_section'.tr(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                verticalSpace(8),
                if (state.recentTransactions.isEmpty)
                  _EmptyHint(text: 'transactions.empty'.tr())
                else
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: state.recentTransactions
                          .map(
                            (transaction) =>
                                TransactionTile(transaction: transaction),
                          )
                          .toList(),
                    ),
                  ).fadeInSlideUp(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final double totalBalance;

  const _TotalBalanceCard({required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.total_balance_label'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          verticalSpace(8),
          Text(
            formatCurrency(totalBalance),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).fadeInScale();
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
