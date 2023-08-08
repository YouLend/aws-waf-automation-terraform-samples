resource "aws_wafv2_web_acl" "wafwebacl" {
  name        = "${var.stage}-web-acl"
  description = "Terraform Created WAFWebACL"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stage}-web-acl"
    sampled_requests_enabled   = true
  }

  dynamic "rule" {
    for_each = var.custom_rule_group != null ? var.custom_rule_group : {}
    content {
      name     = rule.value.name
      priority = rule.value.priority
      override_action {
        none {}
      }

      statement {
        rule_group_reference_statement {
          arn = var.custom_rule_group_arn

          dynamic "rule_action_override" {
            for_each = rule.value.rule_action_override != null ? [1] : []
            content {
              name = rule.value.rule_action_override[0].rule_name
              action_to_use {

                dynamic "allow" {
                  for_each = rule.value.rule_action_override[0].rule_action == "allow" ? [1] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule.value.rule_action_override[0].rule_action == "block" ? [1] : []
                  content {}
                }
                dynamic "captcha" {
                  for_each = rule.value.rule_action_override[0].rule_action == "captcha" ? [1] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule.value.rule_action_override[0].rule_action == "count" ? [1] : []
                  content {}
                }

              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.stage}-${rule.value.name}"
        sampled_requests_enabled   = true
      }


    }
  }

  dynamic "rule" {
    for_each = var.rules != null ? var.rules : {}
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          name        = rule.value.managed_rule_group_statement_name
          vendor_name = rule.value.managed_rule_group_statement_vendor_name
          dynamic "rule_action_override" {
            for_each = rule.value.rule_action_override != null ? [1] : []
            content {
              name = rule.value.rule_action_override[0].rule_name
              action_to_use {

                dynamic "allow" {
                  for_each = rule.value.rule_action_override[0].rule_action == "allow" ? [1] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule.value.rule_action_override[0].rule_action == "block" ? [1] : []
                  content {}
                }
                dynamic "captcha" {
                  for_each = rule.value.rule_action_override[0].rule_action == "captcha" ? [1] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule.value.rule_action_override[0].rule_action == "count" ? [1] : []
                  content {}
                }
              }
            }
          }

          ## Optional Extra configurations
          dynamic "managed_rule_group_configs" {
            for_each = rule.value.managed_rule_group_configs != null ? [1] : []
            content {

              dynamic "aws_managed_rules_bot_control_rule_set" {
                for_each = rule.value.managed_rule_group_configs[0].inspection_level != null ? [1] : []
                content {
                  inspection_level = rule.value.managed_rule_group_configs[0].inspection_level
                }
              }

              dynamic "aws_managed_rules_atp_rule_set" {
                for_each = rule.value.managed_rule_group_configs[0].login_path != null ? [1] : []
                content {
                  login_path = rule.value.managed_rule_group_configs[0].login_path
                  request_inspection {
                    payload_type = "JSON"
                    username_field {
                      identifier = rule.value.managed_rule_group_configs[0].username_field
                    }
                    password_field {
                      identifier = rule.value.managed_rule_group_configs[0].password_field
                    }
                  }
                }
              }

            }

          }
        }


      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.stage}-${rule.value.managed_rule_group_statement_name}"
        sampled_requests_enabled   = true
      }

    }

  }
}


resource "aws_wafv2_web_acl_association" "association" {
  for_each     = toset(var.environments)
  resource_arn = data.terraform_remote_state.external_load_balancer[each.key].outputs.albs[0].external_elb_arn
  web_acl_arn  = aws_wafv2_web_acl.wafwebacl.arn
}