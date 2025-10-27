class JobSubmitException {
  String get title => 'Name already used';
  String get description => 'Please choose a different run name';

  @override
  String toString() {
    return '$title. $description.';
  }
}
