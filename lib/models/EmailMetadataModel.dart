class EmailMetadataModel{
  int? id;

  EmailMetadataModel(
  {this.id, this.template, this.subject, this.recipient, this.occasion});

  String? template;
  int? subject;
  String? recipient;
  int? occasion;
}