resource "aws_wafv2_rule_group" "wafrulegroup" {
  name        = "tf-${var.stage}-custom-rules-group"
  scope       = "REGIONAL"
  description = "Terraform Created Rule Group"
  capacity    = 375
  dynamic "rule" {
    for_each = var.rules
    content {
      name     = "tf-${var.stage}-${rule.value.name}"
      priority = rule.value.priority
      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "captcha" {
          for_each = rule.value.action == "captcha" ? [1] : []
          content {}
        }
        dynamic "challenge" {
          for_each = rule.value.action == "challenge" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

      }
      statement {
        dynamic "geo_match_statement" {
          for_each = rule.value.geo_match != null ? [1] : []
          content {
            country_codes = rule.value.geo_match[0].country_codes
          }
        }

        dynamic "rate_based_statement" {
          for_each = rule.value.rate_based != null ? [1] : []
          content {
            aggregate_key_type = "IP"
            limit              = rule.value.rate_based[0].request_threshold

          }
        }
        dynamic "or_statement" {
          for_each = rule.value.or_statement != null ? [1] : []
          content {
            dynamic "statement" {
              for_each = rule.value.or_statement[0].ip_set != null ? rule.value.or_statement[0].ip_set : []
              content {
                ip_set_reference_statement {
                  arn = statement.value
                }
              }
            }
            dynamic "statement" {
              for_each = rule.value.or_statement[0].xss_match != null ? rule.value.or_statement[0].xss_match : []
              content {
                xss_match_statement {
                  field_to_match {
                    dynamic "body" {
                      for_each = statement.value == "body" ? [1] : []
                      content {}
                    }
                    dynamic "query_string" {
                      for_each = statement.value == "query_string" ? [1] : []
                      content {}
                    }
                    dynamic "uri_path" {
                      for_each = statement.value == "uri_path" ? [1] : []
                      content {}
                    }
                    dynamic "single_header" {
                      for_each = statement.value == "single_header" ? [1] : []
                      content {
                        name = "cookie"
                      }
                    }
                  }
                  text_transformation {
                    priority = 1
                    type     = "URL_DECODE"
                  }

                  text_transformation {
                    priority = 2
                    type     = "HTML_ENTITY_DECODE"
                  }
                }
              }
            }
            dynamic "statement" {
              for_each = rule.value.or_statement[0].sqli_match != null ? rule.value.or_statement[0].sqli_match : []
              content {
                sqli_match_statement {
                  field_to_match {
                    dynamic "body" {
                      for_each = statement.value == "body" ? [1] : []
                      content {}
                    }
                    dynamic "query_string" {
                      for_each = statement.value == "query_string" ? [1] : []
                      content {}
                    }
                    dynamic "uri_path" {
                      for_each = statement.value == "uri_path" ? [1] : []
                      content {}
                    }
                    dynamic "single_header" {
                      for_each = statement.value == "single_header_auth" ? [1] : []
                      content {
                        name = "authorization"
                      }
                    }
                    dynamic "single_header" {
                      for_each = statement.value == "single_header_cookie" ? [1] : []
                      content {
                        name = "cookie"
                      }
                    }

                  }
                  text_transformation {
                    priority = 1
                    type     = "URL_DECODE"
                  }

                  text_transformation {
                    priority = 2
                    type     = "HTML_ENTITY_DECODE"
                  }
                }
              }
            }


          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.stage}-CustomRule-${rule.value.name}"
        sampled_requests_enabled   = true
      }

    }

  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stage}-custom-rule-group-metric"
    sampled_requests_enabled   = true
  }


}