import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _CobrowseEventType {
  static const String remoteControl = "remoteControl";
  static const String sessionUpdate = "sessionUpdate";
}

class _CobrowseTouchEvent {
  static const String touchBegan = "touchBegan";
  static const String touchMoved = "touchMoved";
  static const String touchEnded = "touchEnded";
}

class _CobrowseEventMapKey {
  static const String event = "event";
  static const String eventType = "eventType";
  static const String x = "x";
  static const String y = "y";
}

class WorkaroundCobrowsePlugin {
  static final WorkaroundCobrowsePlugin _instance = WorkaroundCobrowsePlugin._internal();

  static WorkaroundCobrowsePlugin get instance => _instance;

  WorkaroundCobrowsePlugin._internal();

  static const EventChannel _remoteActionEventChannel = EventChannel('Workaround.Cobrowse.RemoteAction');
  static const String _cobrowseEventStream = 'cobrowseEventStream';

  void _handleCobrowseEvent(Object? event) {
    if (event == null) {
      return;
    }

    final eventMap = event as Map? ?? {};
    final eventType = eventMap[_CobrowseEventMapKey.eventType] ?? '';
    if (eventType == _CobrowseEventType.remoteControl) {
      _handleTouchEventMap(eventMap);
    }
  }

  static void _handleTouchEventMap(Map map) {
    final pointerEvent = _getPointEventFromMap(map);
    if (pointerEvent == null) {
      return;
    }

    WidgetsBinding.instance!.handlePointerEvent(pointerEvent);
  }

  static PointerEvent? _getPointEventFromMap(Map map) {
    final x = map[_CobrowseEventMapKey.x] as double;
    final y = map[_CobrowseEventMapKey.y] as double;
    final type = map[_CobrowseEventMapKey.event] as String? ?? '';

    final offset = Offset(x, y);
    switch (type) {
      case _CobrowseTouchEvent.touchBegan:
        return PointerDownEvent(
          pointer: 0,
          position: offset,
        );
      case _CobrowseTouchEvent.touchMoved:
        return PointerMoveEvent(
          pointer: 0,
          position: offset,
        );
      case _CobrowseTouchEvent.touchEnded:
        return PointerUpEvent(
          pointer: 0,
          position: offset,
        );
    }
    return null;
  }

  void listenToAgentRemoteActions() {
    _remoteActionEventChannel.receiveBroadcastStream(_cobrowseEventStream).listen(_handleCobrowseEvent, onError: null);
  }
}
