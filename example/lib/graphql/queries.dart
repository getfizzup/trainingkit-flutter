/// GraphQL documents used by the demo app.
///
/// These mirror the operations used by the React Native sample. The list query
/// returns lightweight workout previews; the session-content query returns the
/// full payload (including `trainingKitToken`) that is handed to the bridge.
///
/// `graphql_flutter` automatically adds `__typename` to every selection set,
/// so the launcher can tell a `WorkoutBlockSession` (classic) from a
/// `WorkoutVideoSession` (video) without requesting it explicitly.
library;

/// Lists the public demo workouts as preview items.
const String getSessions = r'''
query GetSessions {
  publicWorkouts(filters: { tag: "demo" }, configuration: { difficulty: EASY }) {
    edges {
      node {
        ...WorkoutPreviewItem
      }
    }
  }
}

fragment WorkoutPreviewItem on WorkoutPreview {
  id: globalId
  type
  duration
  name
  format
  picture
}
''';

/// Fetches the full session payload for a single workout, by global id.
///
/// The response includes `trainingKitToken`, which the bridge forwards to the
/// native SDK.
const String getSessionContent = r'''
query GetSessionContent($id: ID!) {
  publicWorkoutSession(globalId: $id, configuration: { difficulty: EASY }) {
    ... on WorkoutBlockSession {
      ...WorkoutBlockSessionItem
    }
    ... on WorkoutVideoSession {
      ...WorkoutVideoSessionItem
    }
  }
}

fragment WorkoutBlockSessionItem on WorkoutBlockSession {
  trainingKitToken
  audioSets {
    ...AudioSetItem
  }
  duration
  exercises {
    ...WorkoutExerciseItem
  }
  id: globalId
  sections {
    ...WorkoutSectionItem
  }
  name
  type
}

fragment AudioSetItem on AudioSet {
  duration
  audioFile
  id
  text
  textPhonetic
}

fragment WorkoutExerciseItem on WorkoutExercise {
  id
  name
  execution
  duration
  cover
}

fragment WorkoutSectionItem on WorkoutSection {
  id
  type
  duration
  calories
  executionMode
  name
  optional
  premium
  tasks {
    ... on TaskExercise {
      audioSets { ...AudioSetsItem }
      effortType
      noSeries
      nbSeries
      exerciseId
      side
      nbRepetition
      duration
      asymmetricType
      progressionSegment
      video { ...WorkoutVideoItem }
    }
    ... on TaskRest {
      audioSets { ...AudioSetsItem }
      restTaskType
      restTime
      video { ...WorkoutVideoItem }
    }
  }
}

fragment WorkoutVideoItem on WorkoutVideo {
  cover
  textPrimaryColor
  textSecondaryColor
  tintColor
  video
}

fragment AudioSetsItem on AudioSetTask {
  audioSetsId
  timestamp
  type
}

fragment WorkoutVideoSessionItem on WorkoutVideoSession {
  trainingKitToken
  duration
  id
  name
  reference
  sections {
    ...WorkoutVideoSessionSectionItem
  }
  video {
    ...WorkoutVideoSessionVideoItem
  }
}

fragment WorkoutVideoSessionSectionItem on WorkoutVideoSessionSection {
  id
  type
  start
  end
  calories
  optional
  name
  skipLabel
}

fragment WorkoutVideoSessionVideoItem on WorkoutVideoSessionVideo {
  cover
  end
  start
  textPrimaryColor
  url
}
''';
