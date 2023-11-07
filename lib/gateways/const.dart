import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiEndpoint = dotenv.env['API_ENDPOINT_URL'] ?? 'https://localhost:3000/api/v1';