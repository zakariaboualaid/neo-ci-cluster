module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.24.0"
  name = "${local.project}-vpc-${random_pet.this.id}"

  cidr = local.vpc_cidr
  private_subnets = local.vpc_subnet_private_cidrs
  public_subnets = local.vpc_subnet_public_cidrs
  azs = local.aws_region_azs
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = false
  enable_nat_gateway     = true
  single_nat_gateway     = true
  tags = local.default_tags

  vpc_tags = { Name = "${local.project}-vpc" }
  public_subnet_tags = { "kubernetes.io/role/elb" = "1", "kubernetes.io/cluster/neo-eks" = "shared", Name = "${local.project}-vpc-subnet-public" }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1", "kubernetes.io/cluster/neo-eks" = "shared", Name = "${local.project}-vpc-subnet-private" }
  public_route_table_tags = { Name = "${local.project}-vpc-rt-public" }
  private_route_table_tags = { Name = "${local.project}-vpc-rt-private" }
  igw_tags = { Name = "${local.project}-vpc-igw" }
  nat_eip_tags = { Name = "${local.project}-vpc-nat-eip" }
  nat_gateway_tags = { Name = "${local.project}-vpc-nat" }
}
