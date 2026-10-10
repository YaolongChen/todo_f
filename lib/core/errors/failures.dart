abstract class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = "网络连接不可用"});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = "本地数据读取失败"});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = "未知错误"});
}
