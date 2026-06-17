enum ChatFailure {
  connectionError,
  authError,
  serverError,
  streamError,
  noAgentConfigured,
  unexpected,
}

extension ChatFailureX on ChatFailure {
  String get message {
    switch (this) {
      case ChatFailure.connectionError:
        return 'Cannot connect to NasTech Agent. Check your endpoint.';
      case ChatFailure.authError:
        return 'Authentication failed. Check your API key.';
      case ChatFailure.serverError:
        return 'Agent server error. Please try again.';
      case ChatFailure.streamError:
        return 'Stream interrupted. Please retry.';
      case ChatFailure.noAgentConfigured:
        return 'No agent endpoint configured. Set it in Settings.';
      case ChatFailure.unexpected:
        return 'An unexpected error occurred.';
    }
  }
}
