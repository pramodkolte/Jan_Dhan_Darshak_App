enum CurrentFtp {
  ATM,
  BANK,
  BANK_MITRA,
  POST_OFFICE,
  CSC,
}

class Ftp {
  final ftpId;
  final latitude;
  final longitude;
  final name;
  final address;
  final extra;
  final distance;

  Ftp({
    this.ftpId,
    this.name,
    this.address,
    this.extra,
    this.latitude,
    this.longitude,
    this.distance,
  });
}

class Atm {
  final documentId;
  final latitude;
  final longitude;
  final atmCode;
  final bank;
  final pincode;
  final atmTiming;
  final address;
  final city;
  final district;
  final state;
  final distance;
  Atm({
    this.documentId,
    this.latitude,
    this.longitude,
    this.atmCode,
    this.bank,
    this.pincode,
    this.atmTiming,
    this.address,
    this.city,
    this.district,
    this.state,
    this.distance,
  });
}

class Bank {
  final documentId;
  final latitude;
  final longitude;
  final bankName;
  final branch;
  final ifscCode;
  final bsrCode;
  final contact;
  final pincode;
  final bankTiming;
  final address;
  final city;
  final district;
  final state;
  final distance;
  Bank({
    this.documentId,
    this.latitude,
    this.longitude,
    this.bankName,
    this.branch,
    this.ifscCode,
    this.bsrCode,
    this.contact,
    this.pincode,
    this.bankTiming,
    this.address,
    this.city,
    this.district,
    this.state,
    this.distance,
  });
}

class BankMitra {
  final documentId;
  final latitude;
  final longitude;
  final bankName;
  final mitraName;
  final bankMitraCode;
  final contact;
  final pincode;
  final address;
  final district;
  final state;
  final distance;
  BankMitra({
    this.documentId,
    this.latitude,
    this.longitude,
    this.bankName,
    this.mitraName,
    this.bankMitraCode,
    this.contact,
    this.pincode,
    this.address,
    this.district,
    this.state,
    this.distance,
  });
}

class PostOffice {
  final documentId;
  final latitude;
  final longitude;
  final name;
  final type;
  final pincode;
  final district;
  final state;
  final distance;
  PostOffice({
    this.documentId,
    this.latitude,
    this.longitude,
    this.name,
    this.type,
    this.pincode,
    this.district,
    this.state,
    this.distance,
  });
}

class Csc {
  final documentId;
  final latitude;
  final longitude;
  final id;
  final name;
  final type;
  final block;
  final address;
  final district;
  final state;
  final distance;
  Csc({
    this.documentId,
    this.latitude,
    this.longitude,
    this.id,
    this.name,
    this.type,
    this.block,
    this.address,
    this.district,
    this.state,
    this.distance,
  });
}
