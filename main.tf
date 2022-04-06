provider "aws" {
  region  = "us-east-1"
}


###################################################################################################
# MANAGEMENT VPC
###################################################################################################


# Management VPC
resource "aws_vpc" "management" {
  cidr_block = "10.0.0.0/24"

    tags = {
      Name = "management"
  }

}  

resource "aws_subnet" "management-subnet" {
  vpc_id = aws_vpc.management.id
  cidr_block = "10.0.0.0/24"
  
  #Map public IP -> true
  map_public_ip_on_launch = "true"

      tags = {
      Name = "management-subnet"
  }
}

resource "aws_route_table" "management-route-table" {
  vpc_id = aws_vpc.management.id


  route {
    cidr_block = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-prod.id
  }
  
  route {
    cidr_block = "10.0.2.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-shared.id
  }
  
    route {
    cidr_block = "10.0.3.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-dev.id
  }

 route {
    cidr_block = "10.0.4.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-transit.id
  }


route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.management-igw.id
  }



  tags = {
    Name = "management-route-table"
  }
}


resource "aws_route_table_association" "management-subnet-association" {
  subnet_id      = aws_subnet.management-subnet.id
  route_table_id = aws_route_table.management-route-table.id
}



###################################################################################################
# PROD VPC
###################################################################################################


# Prod vpc

resource "aws_vpc" "prod" {
  cidr_block = "10.0.1.0/24"

    tags = {
      Name = "prod"
  }

}  

resource "aws_subnet" "prod-subnet" {
  vpc_id = aws_vpc.prod.id
  cidr_block = "10.0.1.0/24"
  
      tags = {
      Name = "prod-subnet"
  }
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod.id


  route {
    cidr_block = "10.0.0.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-prod.id
  }

 route {
    cidr_block = "0.0.0.0/0"
    vpc_peering_connection_id = aws_vpc_peering_connection.prod-transit.id
  }

  tags = {
    Name = "prod-route-table"
  }
}


resource "aws_route_table_association" "prod-subnet-association" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}


###################################################################################################
# SHARED VPC
###################################################################################################


# Shared vpc

resource "aws_vpc" "shared" {
  cidr_block = "10.0.2.0/24"

    tags = {
      Name = "shared"
  }

}  

resource "aws_subnet" "shared-subnet" {
  vpc_id = aws_vpc.shared.id
  cidr_block = "10.0.2.0/24"
  
      tags = {
      Name = "shared-subnet"
  }
}

resource "aws_route_table" "shared-route-table" {
  vpc_id = aws_vpc.shared.id


  route {
    cidr_block = "10.0.0.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-shared.id
  }

 route {
    cidr_block = "0.0.0.0/0"
    vpc_peering_connection_id = aws_vpc_peering_connection.shared-transit.id
  }


  tags = {
    Name = "shared-route-table"
  }
}


resource "aws_route_table_association" "shared-subnet-association" {
  subnet_id      = aws_subnet.shared-subnet.id
  route_table_id = aws_route_table.shared-route-table.id
}

###################################################################################################
# DEV VPC
###################################################################################################

resource "aws_vpc" "dev" {
  cidr_block = "10.0.3.0/24"

    tags = {
      Name = "dev"
  }

}  

resource "aws_subnet" "dev-subnet" {
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.3.0/24"
  
      tags = {
      Name = "dev-subnet"
  }
}

resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev.id


  route {
    cidr_block = "10.0.0.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-dev.id
  }

 route {
    cidr_block = "0.0.0.0/0"
    vpc_peering_connection_id = aws_vpc_peering_connection.dev-transit.id
  }


  tags = {
    Name = "dev-route-table"
  }
}


resource "aws_route_table_association" "dev-subnet-association" {
  subnet_id      = aws_subnet.dev-subnet.id
  route_table_id = aws_route_table.dev-route-table.id
}



###################################################################################################
# TRANSIT VPC
###################################################################################################

# Transit VPC
resource "aws_vpc" "transit" {
  cidr_block = "10.0.4.0/23"

    tags = {
      Name = "transit"
  }

}  

resource "aws_subnet" "transit-private-subnet" {
  vpc_id = aws_vpc.transit.id
  cidr_block = "10.0.4.0/24"

      tags = {
      Name = "transit-private-subnet"
  }
}

resource "aws_subnet" "transit-public-subnet" {
  vpc_id = aws_vpc.transit.id
  cidr_block = "10.0.5.0/24"
  
  #Map public IP -> true
  map_public_ip_on_launch = "true"


      tags = {
      Name = "transit-public-subnet"
  }
}


# Subnet < > Route Table Association
resource "aws_route_table_association" "transit-private-route-table" {
  subnet_id      = aws_subnet.transit-private-subnet.id
  route_table_id = aws_route_table.transit-private-route-table.id
}

resource "aws_route_table_association" "transit-public-route-table" {
  subnet_id      = aws_subnet.transit-public-subnet.id
  route_table_id = aws_route_table.transit-public-route-table.id
}


# Routes - private route table
resource "aws_route_table" "transit-private-route-table" {
  vpc_id = aws_vpc.transit.id


  route {
    cidr_block = "10.0.0.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.management-transit.id
  }
  route {
    cidr_block = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.prod-transit.id
  }
  route {
    cidr_block = "10.0.2.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.shared-transit.id
  }
  route {
    cidr_block = "10.0.3.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.dev-transit.id
  }




# modify towards PALO ALTO ENI  
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_network_interface.Palo-Alto-Inbound.id
  }



  tags = {
    Name = "transit-private-route-table"
  }
}

# Routes - public route table
resource "aws_route_table" "transit-public-route-table" {
  vpc_id = aws_vpc.transit.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transit-igw.id
  }


  tags = {
    Name = "transit-public-route-table"
  }
}







###################################################################################################
# PEERING
###################################################################################################

#Peering from Management to Prod

resource "aws_vpc_peering_connection" "management-prod" {
  peer_vpc_id   = aws_vpc.management.id
  vpc_id        = aws_vpc.prod.id
  auto_accept   = true
  
  tags = {
    Name = "VPC Peering between management and prod"
  }
}



#Peering from Management to Shared

resource "aws_vpc_peering_connection" "management-shared" {
  peer_vpc_id   = aws_vpc.management.id
  vpc_id        = aws_vpc.shared.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between management and shared"
  }
}


#Peering from Management to Dev

resource "aws_vpc_peering_connection" "management-dev" {
  peer_vpc_id   = aws_vpc.management.id
  vpc_id        = aws_vpc.dev.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between management and dev"
  }
}

#Peering from Management to Transit

resource "aws_vpc_peering_connection" "management-transit" {
  peer_vpc_id   = aws_vpc.management.id
  vpc_id        = aws_vpc.transit.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between management and transit"
  }
}


#Peering from Prod to Transit

resource "aws_vpc_peering_connection" "prod-transit" {
  peer_vpc_id   = aws_vpc.prod.id
  vpc_id        = aws_vpc.transit.id
  auto_accept   = true
  
  tags = {
    Name = "VPC Peering between prod and transit"
  }
}

#Peering from Shared to Transit

resource "aws_vpc_peering_connection" "shared-transit" {
  peer_vpc_id   = aws_vpc.shared.id
  vpc_id        = aws_vpc.transit.id
  auto_accept   = true
  
  tags = {
    Name = "VPC Peering between shared and transit"
  }
}


#Peering from Dev to Transit

resource "aws_vpc_peering_connection" "dev-transit" {
  peer_vpc_id   = aws_vpc.dev.id
  vpc_id        = aws_vpc.transit.id
  auto_accept   = true
  
  tags = {
    Name = "VPC Peering between dev and transit"
  }
}


###################################################################################################
# IGWs
###################################################################################################

#Management IGW
resource "aws_internet_gateway" "management-igw" {
  vpc_id = aws_vpc.management.id
  depends_on = [aws_vpc.management]

  tags = {
    Name = "management-igw"
  }
}


#Transit IGW
resource "aws_internet_gateway" "transit-igw" {
  vpc_id = aws_vpc.transit.id
  depends_on = [aws_vpc.transit]

  tags = {
    Name = "transit-igw"
  }
}


###################################################################################################
# SECURITY GROUPS
###################################################################################################

# Security Group - Management

resource "aws_security_group" "management-security-group-ssh-http-icmp" {
  name        = "allow http, ssh and icmp"
  description = "allow http, ssh and icmp"
  vpc_id      = aws_vpc.management.id

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "icmp"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-http-ssh-icmp"
  }
}



# Security Group - Prod

resource "aws_security_group" "prod-security-group-ssh-icmp" {
  name        = "allow ssh and icmp"
  description = "allow ssh and icmp"
  vpc_id      = aws_vpc.prod.id

  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "icmp"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-ssh-icmp"
  }
}

# Security Group - Shared

resource "aws_security_group" "shared-security-group-ssh-icmp" {
  name        = "allow ssh and icmp"
  description = "allow ssh and icmp"
  vpc_id      = aws_vpc.shared.id

  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "icmp"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-ssh-icmp"
  }
}


# Security Group - dev

resource "aws_security_group" "dev-security-group-ssh-icmp" {
  name        = "allow ssh and icmp"
  description = "allow ssh and icmp"
  vpc_id      = aws_vpc.dev.id

  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "icmp"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-ssh-icmp"
  }
}


# Security Group - transit - outbound

resource "aws_security_group" "transit-public-security-group-ssh-http-icmp" {
  name        = "allow http, ssh and icmp"
  description = "allow http, ssh and icmp"
  vpc_id      = aws_vpc.transit.id

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "icmp"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-http-ssh-icmp"
  }
}


# Security Group - transit - Inbound - Palo Alto

resource "aws_security_group" "transit-private-security-group-ssh-icmp" {
  name        = "allow ssh and icmp"
  description = "allow ssh and icmp"
  vpc_id      = aws_vpc.transit.id

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "icmp"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-http-ssh-icmp"
  }
}





###################################################################################################
# Create ENI Inbound Interface to Palo Alto Firewall 
###################################################################################################


resource "aws_network_interface" "Palo-Alto-Inbound" {
  subnet_id       = aws_subnet.transit-private-subnet.id
  private_ips     = ["10.0.4.10"]
  security_groups = [aws_security_group.transit-private-security-group-ssh-icmp.id]

}


###################################################################################################
# Create ENI Outbound Interface to Palo Alto Firewall 
###################################################################################################


resource "aws_network_interface" "Palo-Alto-Outbound" {
  subnet_id       = aws_subnet.transit-public-subnet.id
  private_ips     = ["10.0.5.10"]
  security_groups = [aws_security_group.transit-public-security-group-ssh-http-icmp.id]

}
/*
  attachment {
    instance     = aws_instance.test.id
    device_index = 1
    

  }
*/

###################################################################################################
# Create test instances 
###################################################################################################



