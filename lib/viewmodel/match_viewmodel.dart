import 'dart:io';

import 'package:flutter/material.dart';
import 'package:match_42/service/match_service.dart';

enum ChatType {
  talk('수다'),
  eat('밥'),
  subject('과제');

  const ChatType(this.typeName);
  final String typeName;
}

class MatchViewModel extends ChangeNotifier {
  MatchViewModel(String token) : _token = token {
    _init();
  }

  MatchService matchService = MatchService.instance;
  final String _token;
  Map<String, bool> matchStatus = {'밥': false, '수다': false, '과제': false};

  Future<void> _init() async {
    Map<String, dynamic> data = await matchService.getMatchData(_token);

    matchStatus[ChatType.talk.typeName] = data['mealMatchId'] != 0;
    matchStatus[ChatType.subject.typeName] = data['subjectMatchId'] != 0;
    matchStatus[ChatType.talk.typeName] = data['chatMatchId'] != 0;

    print(data);

    notifyListeners();
  }

  Future<void> matchStart(
      {required ChatType type,
      required int capacity,
      bool isGender = false,
      String projectName = '',
      String footType = ''}) {
    return switch (type) {
      ChatType.talk => matchService.startTalkMatch(capacity, _token),
      // ChatType.eat => matchService.start,
      ChatType.subject =>
        matchService.startSubjectMatch(capacity, projectName, _token),
      _ => Future.error(Exception('ChatType Error')),
    }
        .then((value) => _init());
  }

  Future<void> matchStop({required ChatType type}) async {
    return switch (type) {
      ChatType.talk => matchService.stopTalkMatch(_token),
      // ChatType.eat => matchService.start,
      ChatType.subject => matchService.stopSubjectMatch(_token),
      _ => Future.error(Exception('ChatType Error')),
    }
        .then((value) => _init());
  }
}