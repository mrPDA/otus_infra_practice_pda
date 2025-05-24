terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# Network resources
resource "yandex_vpc_network" "network" {
  name = "dataproc-network"
}

# NAT Gateway
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "dataproc-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name       = "dataproc-route-table"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id        = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "dataproc-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.1.0.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

# Security group
resource "yandex_vpc_security_group" "security_group" {
  name        = "dataproc-security-group"
  description = "Security group for Dataproc cluster"
  network_id  = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "YARN web interfaces"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8088
  }

  ingress {
    protocol       = "TCP"
    description    = "Spark History Server"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 18080
  }

  ingress {
    protocol          = "ANY"
    description       = "Internal cluster traffic"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "All outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM roles for service account
resource "yandex_resourcemanager_folder_iam_member" "sa_roles" {
  for_each = toset([
    "storage.admin",
    "dataproc.editor",
    "compute.admin",
    "dataproc.agent",
    "mdb.dataproc.agent",
    "vpc.user",
    "iam.serviceAccounts.user",
    "storage.uploader",
    "storage.viewer",
    "storage.editor"
  ])

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${var.service_account_id}"
}

# Data Proc cluster
resource "yandex_dataproc_cluster" "spark_cluster" {
  depends_on = [yandex_resourcemanager_folder_iam_member.sa_roles]
  
  name               = var.cluster_name
  description        = "Spark cluster for data processing"
  folder_id          = var.folder_id
  service_account_id = var.service_account_id
  zone_id            = var.zone
  security_group_ids = [yandex_vpc_security_group.security_group.id]
  bucket             = var.s3_bucket

  cluster_config {
    version_id = "2.0"

    hadoop {
      services = ["HDFS", "YARN", "SPARK"]
      properties = {
        "yarn:yarn.resourcemanager.am.max-attempts" = 5
      }
      ssh_public_keys = [file(var.public_key_path)]
    }

    # Master node - exactly as specified
    subcluster_spec {
      name = "master"
      role = "MASTERNODE"
      resources {
        resource_preset_id = "s3-c2-m8"
        disk_type_id      = "network-hdd"
        disk_size         = 40
      }
      subnet_id        = yandex_vpc_subnet.subnet.id
      hosts_count      = 1
      assign_public_ip = true
    }

    # Data node - exactly as specified
    subcluster_spec {
      name = "data"
      role = "DATANODE"
      resources {
        resource_preset_id = "s3-c4-m16"
        disk_type_id      = "network-hdd"
        disk_size         = 128
      }
      subnet_id   = yandex_vpc_subnet.subnet.id
      hosts_count = 3
    }
  }
}