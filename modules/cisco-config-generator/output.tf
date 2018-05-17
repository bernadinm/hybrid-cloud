output "userdata" {
  value = "${data.template_file.userdata.rendered}"
}

output "ssh_emulator" {
  value = "${data.template_file.ssh_emulator.rendered}"
}
