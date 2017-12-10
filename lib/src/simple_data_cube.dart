part of data_cube;

class DataRow {
  Map<String, Comparable> dimensions;
  Map<String, num> measures;
}

class HeadlessDataRow {
  List<Comparable> dimensions;
  List<num> measures;
}

abstract class DataCube {

  Map<String, Type> get dimensionDefinitions;
  Map<String, Type> get measureDefinitions;
  List<HeadlessDataRow> get data;

}

class InMemoryDataCube extends DataCube  {
  @override
  Map<String, Type> dimensionDefinitions = {};

  @override
  Map<String, Type> measureDefinitions = {};

  @override
  List<HeadlessDataRow> data = [];

  void add(DataRow dataRow) {
    // Type check dataRow dimensions
    for (var dName in dataRow.dimensions.keys) {
      if (dimensionDefinitions[dName] != null && dimensionDefinitions[dName] != dataRow.dimensions[dName].runtimeType) {
        throw new ArgumentError.value(dataRow.dimensions[dName].runtimeType, dName,
            'Incompatible dimension type, was expecting ${dimensionDefinitions[dName]}');
      }
    }

    Set<String> newDimensionNames = dataRow.dimensions.keys.where((dim) => dimensionDefinitions[dim] == null).toSet();
    if (newDimensionNames.isNotEmpty) {
      // Extend dimension definitions with new values
      for (var name in newDimensionNames) {
        dimensionDefinitions[name] = dataRow.dimensions[name].runtimeType;
      }
      // Patch existing data rows with new dimensions
      for (var row in data) {
        row.dimensions.addAll(newDimensionNames.map((_) => null));
      }
    }

    // Patch new data row with earlier dimensions that are not present in current data
    HeadlessDataRow newRow = new HeadlessDataRow()
      ..dimensions = dimensionDefinitions.keys.map((key) => dataRow.dimensions[key]).toList();

    // Type check dataRow dimensions
    for (var mName in dataRow.measures.keys) {
      if (measureDefinitions[mName] != null && measureDefinitions[mName] != dataRow.measures[mName].runtimeType) {
        throw new ArgumentError.value(dataRow.measures[mName].runtimeType, mName, 'Incompatible measure type');
      }
    }

    Set<String> newMeasureNames = dataRow.measures.keys.where((ms) => measureDefinitions[ms] == null).toSet();
    if (newMeasureNames.isNotEmpty) {
      // Extend measure definitions with new values
      for (var name in newMeasureNames) {
        measureDefinitions[name] = dataRow.measures[name].runtimeType;
      }
    }

    // Patch new data row with earlier dimensions that are not present in current data
    newRow.measures = measureDefinitions.keys.map((key) => dataRow.measures[key]).toList();
  }

  DataCube query() {
    return new InMemoryDataCube();
  }
}
