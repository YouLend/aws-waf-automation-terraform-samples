variable "ip_set" {
  type = map(object({
    name    = string
    description  = string
    ip_address_version = string
    addresses = list(string)      
  }))
}