module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "5.0.0"

  name = "${local.project}-nlb-${random_pet.this.id}"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

	load_balancer_type = "network"

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = module.acm.this_acm_certificate_arn
      target_group_index = 1
    },
  ]


  target_groups = [
    {
      name_prefix          = "t1-"
      backend_protocol     = "TCP"
      backend_port         = 31000
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
    {
      name_prefix          = "t2-"
      backend_protocol     = "TCP"
      backend_port         = 32000
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
  ]

  tags = merge(local.default_tags, {
    "Name" = "${local.project}-alb"
  })
}
