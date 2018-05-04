output "site_one_config" {
  value = "${data.template_file.site_one.rendered}"
}

output "site_two_config" {
  value = "${data.template_file.site_two.rendered}"
}
