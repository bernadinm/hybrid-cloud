output "userdata" {
  value = "${data.template_file.userdata.rendered}"
}
