import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:filemanager/bootstrap.dart';
import 'package:meta/meta.dart';

class DirectoryPathBloc extends Bloc<DirectoryPathEvent, DirectoryPathState> {
  static DirectoryPathState defState = new DirectoryPathState(
    [''], // `''` mengarah ke root directory
    [''].first,
    [''].last,
  );

  DirectoryPathBloc() : super(DirectoryPathBloc.defState) {
    on<DirectoryPathEvent>((event, emit) => emit(mapEventToState(event)));
  }

  DirectoryPathState mapEventToState(
    DirectoryPathEvent event,
  ) {
    if (event is PopLastPath) {
      if (event.paths.length > 1) {
        event.paths.removeLast();
      }
      return DirectoryPathState(
        event.paths,
        event.paths.first,
        event.paths.last,
      );
    } else if (event is PushNewPath) {
      if (!event.paths.haveValue(event.newPath)) {
        event.paths.add(event.newPath);
      }
      return DirectoryPathState(
        event.paths,
        event.paths.first,
        event.paths.last,
      );
    } else if (event is RemovePathAfterIndex) {
      List<String> newPaths = event.paths.removeAfter(event.index);
      return DirectoryPathState(newPaths, newPaths.first, newPaths.last);
    } else if (event is RefreshPath) {
      return DirectoryPathState(
        event.paths,
        event.paths.first,
        event.paths.last,
      );
    } else {
      return DirectoryPathBloc.defState;
    }
  }

  // ...
}

@immutable
abstract class DirectoryPathEvent {
  final List<String> paths;

  const DirectoryPathEvent(this.paths);
}

class RefreshPath extends DirectoryPathEvent {
  RefreshPath(List<String> paths) : super(paths);
}

class PopLastPath extends DirectoryPathEvent {
  PopLastPath(List<String> paths) : super(paths);
}

class RemovePathAfterIndex extends DirectoryPathEvent {
  final int index;
  RemovePathAfterIndex(this.index, List<String> paths) : super(paths);
}

class PushNewPath extends DirectoryPathEvent {
  final String newPath;

  PushNewPath(this.newPath, List<String> paths) : super(paths);
}

class DirectoryPathState {
  final List<String> paths;
  final String firstPath, lastPath;

  DirectoryPathState(this.paths, this.firstPath, this.lastPath);
}
