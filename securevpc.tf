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