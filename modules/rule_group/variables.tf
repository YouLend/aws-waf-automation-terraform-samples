
variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`, `sandbox`)"
}



variable "rules" {
  type = map(object({
    name     = string
    priority = number
    action   = string
    geo_match = list(object({
      country_codes = list(string)
    }))
    rate_based = list(object({
      request_threshold = number
    }))
    or_statement = list(object({
      ip_set     = list(string)
      xss_match  = list(string)
      sqli_match = list(string)
    }))

  }))
}