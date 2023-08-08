
variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`, `sandbox`)"
}

variable "environments" {
  type        = list(string)
  description = "A list of environments (e.g. [`devops`,`barbican`....etc])"

}


variable "custom_rule_group_arn" {
  type        = string
  description = "ARN of the external application load balancer"
}

variable "rules" {
  type = map(object({
    name                                     = string
    priority                                 = number
    managed_rule_group_statement_name        = string
    managed_rule_group_statement_vendor_name = string
    rule_action_override = list(object({
      rule_name   = string
      rule_action = string
    }))
    managed_rule_group_configs = list(object({
      inspection_level = string
      login_path       = string
      username_field   = string
      password_field   = string
    }))

  }))
}

variable "custom_rule_group" {
  type = map(object({
    name     = string
    priority = number
    rule_action_override = list(object({
      rule_name   = string
      rule_action = string
    }))
  }))
}