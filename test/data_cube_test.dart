import 'package:data_cube/data_cube.dart';
import 'package:test/test.dart';
import 'sample_data.dart';

void main() {
  group('InMemoryDataCube tests', () {
    var dataCube = new InMemoryDataCube();

    setUp(() {
      for (var row in sampleData) {
        var dataRow = new DataRow()
          ..dimensions = {
            'firstName': row['dimensions']['firstName'],
            'lastName': row['dimensions']['lastName'],
            'birthDate': DateTime.parse(row['dimensions']['birthDate']),
            'gender': row['dimensions']['gender'],
            'education': row['dimensions']['education'],
            'state': row['dimensions']['state']
          }
          ..measures = {
            'balance': row['measures']['balance'] is String
                ? double.parse(row['measures']['balance'])
                : row['measures']['balance'].toDouble(),
            'age': row['measures']['age'],
            'children': row['measures']['children']
          };
        dataCube.add(dataRow);
      }
    });

    test('Read successful', () {
      expect(dataCube.dimensionDefinitions.length, 6);
      expect(dataCube.measureDefinitions.length, 3);
      expect(dataCube.dimensionDefinitions['birthDate'] == DateTime, isTrue);
    });
  });
}
