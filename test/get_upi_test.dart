

// class MockGetUpiPlatform
//     with MockPlatformInterfaceMixin
//     implements GetUpiPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final GetUpiPlatform initialPlatform = GetUpiPlatform.instance;

//   test('$MethodChannelGetUpi is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelGetUpi>());
//   });

//   test('getPlatformVersion', () async {
//     GetUpi getUpiPlugin = GetUpi();
//     MockGetUpiPlatform fakePlatform = MockGetUpiPlatform();
//     GetUpiPlatform.instance = fakePlatform;

//     expect(await getUpiPlugin.getPlatformVersion(), '42');
//   });
// }
