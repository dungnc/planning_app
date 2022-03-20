import 'dart:math';

import 'package:agileplanning/components/poker/participant_status.component.dart';
import 'package:agileplanning/models/room_participant.model.dart';
import 'package:flutter/material.dart';

class RoomGridComponent extends StatelessWidget {
  final Iterable<RoomParticipant> participants;
  final bool hideVotes;
  final String id;

  RoomGridComponent({this.participants, this.hideVotes, this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = _getMaxDimensions(constraints);
          return SingleChildScrollView(
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              runSpacing: 16.0,
              spacing: 28.0,
              children: participants
                  .map((participant) => ParticipantStatusComponent(
                        participant: participant,
                        size: size,
                        hideVote: id == null
                            ? hideVotes
                            : hideVotes && participant.id != id,
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  /// Calculate the maximum dimensions possible for the poker grid
  /// component. The grid should be about three elements wide and about
  /// four elements high, with some room for spacing in between.
  double _getMaxDimensions(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth * 0.27;
    final maxHeight = constraints.maxHeight * 0.24;
    return min(maxWidth, maxHeight);
  }
}
