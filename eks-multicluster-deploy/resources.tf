resource "random_pet" "cluster_name" {
  count = var.count
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "eks_public_subnet" {
  count = var.count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

resource "aws_route_table_association" "eks_public_subnet_association" {
  count          = var.count
  subnet_id      = aws_subnet.eks_public_subnet[count.index].id
  route_table_id = aws_route_table.eks_public_route_table.id
}

resource "aws_nat_gateway" "eks_nat_gateway" {
  allocation_id = aws_eip.eks_nat_eip.id
  subnet_id     = aws_subnet.eks_public_subnet[0].id

  tags = {
    Name = "eks-nat-gateway"
  }
}

resource "aws_eip" "eks_nat_eip" {
  vpc = true
}

resource "aws_subnet" "eks_private_subnet" {
  count = var.count
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "eks-private-subnet-${count.index}"
  }
}

resource "aws_route_table" "eks_private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gateway.id
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

resource "aws_route_table_association" "eks_private_subnet_association" {
  count          = var.count
  subnet_id      = aws_subnet.eks_private_subnet[count.index].id
  route_table_id = aws_route_table.eks_private_route_table.id
}

data "aws_eks_addon_version" "coredns" {
  addon_name          = "coredns"
  kubernetes_version  = "1.29" # Specify the Kubernetes version
  most_recent         = true
}

data "aws_eks_addon_version" "ebs_csi_driver" {
  addon_name          = "aws-ebs-csi-driver"
  kubernetes_version  = "1.29" # Specify the Kubernetes version
  most_recent         = true
}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name          = "vpc-cni"
  kubernetes_version  = "1.29" # Specify the Kubernetes version
  most_recent         = true
}

resource "aws_eks_cluster" "eks_cluster" {
  count           = var.count
  name            = "${random_pet.cluster_name[count.index].id}-eks-cluster"
  role_arn        = aws_iam_role.eks_cluster_role.arn
  version         = "1.29" # Specify the Kubernetes version for the EKS cluster

  vpc_config {
    subnet_ids = aws_subnet.eks_private_subnet[*].id
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy, 
                aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceController]
}

resource "aws_eks_node_group" "eks_node_group" {
  count           = var.count
  cluster_name    = aws_eks_cluster.eks_cluster[count.index].name
  node_group_name = "pool-1"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = aws_subnet.eks_private_subnet[*].id
  version         = "1.29" # Specify the Kubernetes version for the node group

  scaling_config {
    desired_size = 1
    max_size     = var.count
    min_size     = 1
  }

  instance_types = ["t3.medium"]  # Update this to your preferred instance type
  capacity_type  = "ON_DEMAND"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

data "aws_availability_zones" "available" {}

resource "aws_eks_addon" "coredns_addon" {
  count = var.count
  cluster_name   = aws_eks_cluster.eks_cluster[count.index].name
  addon_name     = "coredns"
  addon_version  = data.aws_eks_addon_version.coredns.version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "ebs_csi_driver_addon" {
  count = var.count
  cluster_name   = aws_eks_cluster.eks_cluster[count.index].name
  addon_name     = "aws-ebs-csi-driver"
  addon_version  = data.aws_eks_addon_version.ebs_csi_driver.version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni_addon" {
  count = var.count
  cluster_name   = aws_eks_cluster.eks_cluster[count.index].name
  addon_name     = "vpc-cni"
  addon_version  = data.aws_eks_addon_version.vpc_cni.version
  resolve_conflicts = "OVERWRITE"
}
