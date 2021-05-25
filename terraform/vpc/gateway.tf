resource "aws_eip" "nat" {
  vpc   = true
  count = length(var.zones)
}

resource "aws_nat_gateway" "nat-gateway" {
  count = length(var.zones)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
}
