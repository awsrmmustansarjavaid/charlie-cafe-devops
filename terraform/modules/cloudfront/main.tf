resource "aws_cloudfront_distribution" "this" {
enabled=true
comment="${var.name_prefix} Charlie Cafe frontend via ALB"
is_ipv6_enabled=false
default_root_object="cafe-admin-dashboard.html"
price_class="PriceClass_100"
origin {
domain_name=var.alb_dns_name
origin_id="charlie-cafe-alb-origin"
custom_origin_config {
http_port=80
https_port=443
origin_protocol_policy="http-only"
origin_ssl_protocols=["TLSv1.2"] } }
default_cache_behavior {
target_origin_id="charlie-cafe-alb-origin"
viewer_protocol_policy="redirect-to-https"
allowed_methods=["DELETE","GET","HEAD","OPTIONS","PATCH","POST","PUT"]
cached_methods=["GET","HEAD"]
compress=true
cache_policy_id=data.aws_cloudfront_cache_policy.disabled.id
origin_request_policy_id=data.aws_cloudfront_origin_request_policy.all_viewer.id }
restrictions {
geo_restriction {
restriction_type="none" } }
viewer_certificate {
cloudfront_default_certificate=true }
tags=var.tags }


data "aws_cloudfront_cache_policy" "disabled" {
name="Managed-CachingDisabled" }


data "aws_cloudfront_origin_request_policy" "all_viewer" {
name="Managed-AllViewer" }
