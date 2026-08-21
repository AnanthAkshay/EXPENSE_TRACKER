import '../core/network/api_client.dart';
import '../models/wrapped_story.dart';

class WrappedService {
  final ApiClient _apiClient;

  WrappedService(this._apiClient);

  Future<WrappedStoryModel> getWrappedStory(String month) async {
    final res = await _apiClient.get('/wrapped/$month');
    return WrappedStoryModel.fromJson(res as Map<String, dynamic>);
  }
}
