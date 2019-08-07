output "public_ip_front" {
  value = "${aws_instance.front.public_ip}"
}
output "public_ip_webservice" {
  value = "${aws_instance.webservice.public_ip}"
}
