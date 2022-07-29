resource "aws_dynamodb_table" "Files" {
  name = "${var.table_name}"
  billing_mode = "PROVISIONED"
  read_capacity= "30"
  write_capacity= "30"
  attribute {
    name = "${var.attribute}"
    type = "S"
  }
  hash_key = "${var.hash_key}"
}
