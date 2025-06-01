terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

resource "null_resource" "run_batch" {
  provisioner "local-exec" {
    command     = "import_vm.bat"
    interpreter = ["cmd", "/C"]
  }
}

resource "null_resource" "wait_for_vm" {
  depends_on = [null_resource.run_batch]
  provisioner "local-exec" {
    command     = "ping -n 60 127.0.0.1 > nul"
    interpreter = ["cmd", "/C"]
  }
}

resource "null_resource" "copy_files" {
  depends_on = [null_resource.wait_for_vm]

  provisioner "local-exec" {
    command     = "copy_files.bat"
    interpreter = ["cmd", "/C"]
  }
}

resource "null_resource" "execute_dc_script" {
  depends_on = [null_resource.copy_files]

  provisioner "local-exec" {
    command     = "run_remotely.bat"
    interpreter = ["cmd", "/C"]
  }
}
