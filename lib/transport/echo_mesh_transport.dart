abstract class EchoMeshTransport {
  Future<void> send(List<int> data);
  Stream<List<int>> receive();
}