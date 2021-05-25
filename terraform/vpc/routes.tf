resource "aws_route_table" "internet-gw-route" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet-gw-route"
  }
}

resource "aws_route_table" "nat-gw-route" {
  count  = length(var.private_cidrs)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "nat-gw-route-${count.index + 1}"
  }
}

resource "aws_route" "internet-gw-route" {
  route_table_id            = aws_route_table.internet-gw-route.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.main.id
  depends_on                = [aws_route_table.internet-gw-route]
}

resource "aws_route" "nat-gw-routes" {
  count                     = length(var.private_cidrs)
  route_table_id            = element(aws_route_table.nat-gw-route.*.id, count.index)
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = element(aws_nat_gateway.nat-gateway.*.id, count.index)
  depends_on                = [aws_route_table.nat-gw-route]
}

resource "aws_route_table_association" "public-subnets" {
  count          = length(var.public_cidrs)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.internet-gw-route.id
}

resource "aws_route_table_association" "private-subnets" {
  count          = length(var.private_cidrs)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.nat-gw-route.*.id, count.index)
}