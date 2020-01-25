module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "5.0.0"

  name = "${local.project}-alb"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_groups = [module.security_group_alb.this_security_group_id]
  http_tcp_listeners = [
    {
      "port"               = 80
      "protocol"           = "HTTP"
      "target_group_index" = 0
    }
  ]

  target_groups = [
    {
      "name"             								 = "${local.project}-tg-eks"
      "backend_protocol" 								 = "HTTP"
      "backend_port"     								 = 30000
      "slow_start"       								 = 0
      "cookie_duration"                  = 86400
      "deregistration_delay"             = 300
   	  "health_check_interval"            = 10
      "health_check_healthy_threshold"   = 4
      "health_check_path"                = "/healthz"
      "health_check_port"                = "traffic-port"
      "health_check_timeout"             = 5
      "health_check_unhealthy_threshold" = 3
      "health_check_matcher"             = "200-299"
      "stickiness_enabled"               = true
      "target_type"                      = "instance"
      "slow_start"                       = 0
    }
  ]

  tags = merge(local.default_tags, {
    "Name" = "${local.project}-alb"
  })
}
