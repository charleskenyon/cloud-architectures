resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65016
  ip_address = var.customer_gateway_device_external_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.arch}-on-prem-customer-gateway"
  }
}

resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id
  type                = aws_customer_gateway.cgw.type
  enable_acceleration = false # change true
  static_routes_only  = true
}

# static on-premises route, todo add bgp
resource "aws_ec2_transit_gateway_route" "tgw_vpn_route" {
  destination_cidr_block         = var.customer_gateway_device_lan_cidr
  transit_gateway_attachment_id  = aws_vpn_connection.vpn_connection.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}

resource "aws_route" "vpc1_tgw_vpn_route" {
  route_table_id         = aws_route_table.vpc1_route_table.id
  destination_cidr_block = var.customer_gateway_device_lan_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc2_tgw_vpn_route" {
  route_table_id         = aws_route_table.vpc2_route_table.id
  destination_cidr_block = var.customer_gateway_device_lan_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}