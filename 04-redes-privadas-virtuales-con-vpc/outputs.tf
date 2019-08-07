output "public_ip_front" {
  value = "${aws_instance.front.public_ip}"
}
output "public_ip_bdd" {
  value = "${aws_instance.bdd.public_ip}"
}
output "private_ip_front" {
  value = "${aws_instance.front.private_ip}"
}
output "private_ip_bdd" {
  value = "${aws_instance.bdd.private_ip}"
}
