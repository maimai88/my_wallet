
const tblChange = "Change";

const fldTables = "tables";
const fldTableName = "name";
const fldTableChange = "change";
const fldTableTimeStamp = "timestamp";

const fldDevices = "devices";

class Change {
  final List<Table> tables;
  final double lastDeviceUpdate;

  Change(this.tables, this.lastDeviceUpdate);
}

class Table {
  final String name;
  final String documentId;
  final int timestamp;

  Table(this.name, this.documentId, this.timestamp);

  Table.from(String tableName, Map<String, dynamic> data)
      : this.name = tableName,
        this.documentId = "${data[fldTableChange]}",
        this.timestamp = int.parse("${data[fldTableTimeStamp]}");
}

class Device {
  final String uuid;
  final String platform;
  final String deviceName;
  final int timestamp;

  Device(this.uuid, this.platform, this.deviceName, this.timestamp);
}