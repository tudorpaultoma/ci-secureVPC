/*******************
VPC Resource
*******************/

resource "tencentcloud_vpc" "secureVPC" {

  #-----Required parameters-----
  name              = "vpc-${var.project-name}-${var.region}-${var.environment}-01"
  cidr_block        = var.vpc_cidr
  
  #-----Optional but highly recommended parameters-----
  tags = {
    "name"          = "vpc-${var.project-name}-${var.region}-${var.environment}-01"
    "owner"         = var.tag-owner
    "purpose"       = var.tag-purpose
    "environment"   = var.environment
    "security_lvl"  = var.tag-security_lvl
    "cost_center"   = var.tag-cost_center
  }

  #disable multicast in the VPC, unless specifically needed
  is_multicast      = var.multicast
  
  #-----Just Optional parameters-----
  #dns_servers      = var.dns_servers
}

/*******************
Subnet Resources
*******************/

resource "tencentcloud_subnet" "publicSubnet" {

  #-----Required parameters-----
  name              = "subnet-${var.project-name}-public-${var.environment}-01"
  availability_zone = "${var.region}-${var.AZ-1}"
  vpc_id            = tencentcloud_vpc.secureVPC.id
  cidr_block        = cidrsubnet("${var.vpc_cidr}", 4, 1)
  
  #-----Optional but highly recommended parameters-----
  route_table_id    = tencentcloud_route_table.rt-public.id
  is_multicast      = var.multicast

  #-----Just Optional parameters-----
  #tags = {}
}

resource "tencentcloud_subnet" "serviceSubnet" {

  #-----Required parameters-----
  name              = "subnet-${var.project-name}-service-${var.environment}-01"
  availability_zone = "${var.region}-${var.AZ-1}"
  vpc_id            = tencentcloud_vpc.secureVPC.id
  cidr_block        = cidrsubnet("${var.vpc_cidr}", 4, 2)
  
  #-----Optional but highly recommended parameters-----
  route_table_id    = tencentcloud_route_table.rt-service.id
  is_multicast      = var.multicast

  #-----Just Optional parameters-----
  #tags = {}
}

resource "tencentcloud_subnet" "dataSubnet" {

  #-----Required parameters-----
  name              = "subnet-${var.project-name}-data-${var.environment}-01"
  availability_zone = "${var.region}-${var.AZ-1}"
  vpc_id            = tencentcloud_vpc.secureVPC.id
  cidr_block        = cidrsubnet("${var.vpc_cidr}", 4, 3)
  
  #-----Optional but highly recommended parameters-----
  route_table_id    = tencentcloud_route_table.rt-data.id
  is_multicast      = var.multicast

  #-----Just Optional parameters-----
  #tags = {}
}

/*******************
EIP Resource
*******************/

resource "tencentcloud_eip" "natgw-EIP" {

  #-----Required parameters-----
  name = "eip-${var.project-name}-01"
}


/*******************
NAT Gateway Resource
*******************/

resource "tencentcloud_nat_gateway" "secureVPC-NATGW" {

  #-----Required parameters-----
  name             = "natgw-${var.project-name}-public"
  vpc_id           = tencentcloud_vpc.secureVPC.id
  bandwidth        = var.natgw-bandwidth
  max_concurrent   = var.natgw-max-concurrent
  assigned_eip_set = ["${tencentcloud_eip.natgw-EIP.public_ip}"]
}

/*******************
Route Table Resources
*******************/

resource "tencentcloud_route_table" "rt-public" {
  
  #-----Required parameters-----
  name              = "rt-${var.project-name}-public"
  vpc_id            = tencentcloud_vpc.secureVPC.id

  #-----Optional but highly recommended parameters-----
  #-----Just Optional parameters-----
  #tags = {}
}

resource "tencentcloud_route_table" "rt-service" {
  
  #-----Required parameters-----
  name              = "rt-${var.project-name}-service"
  vpc_id            = tencentcloud_vpc.secureVPC.id

  #-----Optional but highly recommended parameters-----
  #-----Just Optional parameters-----
  #tags = {}
}

resource "tencentcloud_route_table" "rt-data" {
  
  #-----Required parameters-----
  name              = "rt-${var.project-name}-data"
  vpc_id            = tencentcloud_vpc.secureVPC.id

  #-----Optional but highly recommended parameters-----
  #-----Just Optional parameters-----
  #tags = {}
}

/*******************
Route Table Entries
*******************/


resource "tencentcloud_route_table_entry" "public-default-route" {

  #-----Required parameters-----
  route_table_id         = tencentcloud_route_table.rt-public.id
  destination_cidr_block = var.rt-public-entry1-destination
  next_type              = var.rt-public-entry1-next_hop_type
  next_hub               = tencentcloud_nat_gateway.secureVPC-NATGW.id

  #-----Optional but highly recommended parameters-----
  description            = var.rt-public-entry1-description
}

resource "tencentcloud_route_table_entry" "service-default-route" {

  #-----Required parameters-----
  route_table_id         = tencentcloud_route_table.rt-service.id
  destination_cidr_block = var.rt-service-entry1-destination
  next_type              = var.rt-service-entry1-next_hop_type
  next_hub               = tencentcloud_nat_gateway.secureVPC-NATGW.id

  #-----Optional but highly recommended parameters-----
  description            = var.rt-service-entry1-description
}

resource "tencentcloud_route_table_entry" "data-default-route" {

  #-----Required parameters-----  
  route_table_id         = tencentcloud_route_table.rt-data.id
  destination_cidr_block = var.rt-data-entry1-destination
  next_type              = var.rt-data-entry1-next_hop_type
  next_hub               = tencentcloud_nat_gateway.secureVPC-NATGW.id

  #-----Optional but highly recommended parameters-----
  description            = var.rt-data-entry1-description
}

resource "tencentcloud_security_group" "sg-secureVPC-publicCVMs" {

  #-----Required parameters-----
  name              = "sg-${var.project-name}-publicCVMs"

  #-----Optional but highly recommended parameters-----
  project_id  = var.project-id
  description = "sg-${var.project-name}-publicCVMs-${var.tag-owner}-${var.tag-purpose}-${var.environment}-${var.tag-security_lvl}"
  tags = {
    "owner"         = var.tag-owner
    "purpose"       = var.tag-purpose
    "environment"   = var.environment
    "security_lvl"  = var.tag-security_lvl
  }
}

resource "tencentcloud_security_group" "sg-secureVPC-serviceCVMs" {

  #-----Required parameters-----
  name        = "sg-${var.project-name}-serviceCVMs"

  #-----Optional but highly recommended parameters-----
  
  project_id  = var.project-id
  description = "sg-${var.project-name}-serviceCVMs-${var.tag-owner}-${var.tag-purpose}-${var.environment}-${var.tag-security_lvl}"
  tags = {
    "owner"         = var.tag-owner
    "purpose"       = var.tag-purpose
    "environment"   = var.environment
    "security_lvl"  = var.tag-security_lvl
  }
}

resource "tencentcloud_security_group" "sg-secureVPC-dataCVMs" {

  #-----Required parameters-----
  name        = "sg-${var.project-name}-dataCVMs"

  #-----Optional but highly recommended parameters-----
  project_id  = var.project-id
  description = "sg-${var.project-name}-dataCVMs-${var.tag-owner}-${var.tag-purpose}-${var.environment}-${var.tag-security_lvl}"
  tags = {
    "owner"         = var.tag-owner
    "purpose"       = var.tag-purpose
    "environment"   = var.environment
    "security_lvl"  = var.tag-security_lvl
  }
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-publicCVMs-r1" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-publicCVMs.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "TCP"
  port_range        = "22"
  policy            = "ACCEPT"
  description       = "allow ssh"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-publicCVMs-r2" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-publicCVMs.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "TCP"
  port_range        = "3389"
  policy            = "ACCEPT"
  description       = "allow rdp"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-publicCVMs-r3" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-publicCVMs.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "ICMP"
  #port_range        = ""
  policy            = "ACCEPT"
  description       = "allow icmp"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-publicCVMs-r4" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-publicCVMs.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  #ip_protocol       = "ALL"
  #port_range        = "ALL"
  policy            = "ACCEPT"
  description       = "allow all internal"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-serviceCVMs-r1" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-serviceCVMs.id
  type              = "ingress"
  source_sgid       = tencentcloud_security_group.sg-secureVPC-publicCVMs.id
  ip_protocol       = "TCP"
  port_range        = "22"
  policy            = "ACCEPT"
  description       = "allow ssh"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-serviceCVMs-r2" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-serviceCVMs.id
  type              = "ingress"
  source_sgid       = tencentcloud_security_group.sg-secureVPC-publicCVMs.id
  ip_protocol       = "TCP"
  port_range        = "3389"
  policy            = "ACCEPT"
  description       = "allow rdp"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-serviceCVMs-r3" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-serviceCVMs.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "ICMP"
  #port_range        = ""
  policy            = "ACCEPT"
  description       = "allow icmp"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-serviceCVMs-r4" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-serviceCVMs.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  #ip_protocol       = "ALL"
  #port_range        = "ALL"
  policy            = "ACCEPT"
  description       = "allow all internal"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-dataCVMs-r1" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-dataCVMs.id
  type              = "ingress"
  source_sgid       = tencentcloud_security_group.sg-secureVPC-serviceCVMs.id
  ip_protocol       = "TCP"
  port_range        = "22"
  policy            = "ACCEPT"
  description       = "allow ssh"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-dataCVMs-r2" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-dataCVMs.id
  type              = "ingress"
  source_sgid       = tencentcloud_security_group.sg-secureVPC-serviceCVMs.id
  ip_protocol       = "TCP"
  port_range        = "3389"
  policy            = "ACCEPT"
  description       = "allow rdp"
}

resource "tencentcloud_security_group_rule" "sg-secureVPC-dataCVMs-r3" {
  security_group_id = tencentcloud_security_group.sg-secureVPC-dataCVMs.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  #ip_protocol       = "ALL"
  #port_range        = "ALL"
  policy            = "ACCEPT"
  description       = "allow all internal"
}