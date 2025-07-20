library x_overlay;


import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

part 'src/x_navigator_observer.dart';
part 'src/internal.dart';
part 'src/x_dialog.dart';
part 'src/x_toast.dart';
part 'src/x_loading.dart';
part 'src/x_overlay_entry.dart';

final XDialogCompanion XDialog = XDialogCompanion();
final ToastCompanion XToast = ToastCompanion();
final XLoadingCompanion XLoading = XLoadingCompanion();