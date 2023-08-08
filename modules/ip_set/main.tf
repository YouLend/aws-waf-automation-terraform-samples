resource "aws_wafv2_ip_set" "ip_set" {
for_each = var.ip_set
  name               = each.value["name"]
  description        = each.value["description"]
  scope              = "REGIONAL"
  ip_address_version = each.value["ip_address_version"]
  addresses          = each.value["addresses"]
}