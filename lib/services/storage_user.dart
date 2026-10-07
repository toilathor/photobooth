/// User identity exposed by storage providers.
class StorageUser {
  final String id;
  final String? email;
  final String? displayName;

  const StorageUser({required this.id, this.email, this.displayName});
}
