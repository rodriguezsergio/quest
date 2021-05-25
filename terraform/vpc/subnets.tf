resource "aws_subnet" "public" {
  count = length(var.public_cidrs)
  depends_on = [aws_internet_gateway.main]
  map_public_ip_on_launch = true

  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_cidrs, count.index)
  availability_zone = element(var.zones, count.index)

  tags = {
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private_cidrs, count.index)
  availability_zone = element(var.zones, count.index)

  tags = {
    Type = "private"
  }
}
