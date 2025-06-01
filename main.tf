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

resource "null_resource" "wait_for_dc_ready" {
  depends_on = [null_resource.execute_dc_script]

  provisioner "local-exec" {
    command     = "echo Czekam 15 minut na zakończenie promocji DC... && ping -n 900 127.0.0.1 > nul"
    interpreter = ["cmd", "/C"]
  }
}

resource "null_resource" "configure_additional_services" {
  depends_on = [null_resource.wait_for_dc_ready]

  provisioner "local-exec" {
    command     = "configure_services.bat"
    interpreter = ["cmd", "/C"]
  }
}

# Konfiguracja OU i użytkowników
resource "null_resource" "create_users_and_ous" {
  depends_on = [null_resource.configure_additional_services]

  provisioner "local-exec" {
    command     = "create_users.bat"
    interpreter = ["cmd", "/C"]
  }
}

resource "null_resource" "create_advanced_gpos" {
  depends_on = [null_resource.create_users_and_ous]

  provisioner "local-exec" {
    command     = "create_advanced_gpo.bat"
    interpreter = ["cmd", "/C"]
  }
}

resource "null_resource" "create_shares" {
  depends_on = [null_resource.create_users_and_ous, null_resource.create_advanced_gpos]

  provisioner "local-exec" {
    command     = "create_shares.bat"
    interpreter = ["cmd", "/C"]
  }
}

# Importowanie Windows 10 z OVA
resource "null_resource" "import_win10" {
  depends_on = [null_resource.create_shares] # Po zakończeniu konfiguracji domeny

  provisioner "local-exec" {
    command     = "import_win10.bat"
    interpreter = ["cmd", "/C"]
  }
}

# Czekanie na uruchomienie maszyny Windows 10
resource "null_resource" "wait_for_win10_boot" {
  depends_on = [null_resource.import_win10]

  provisioner "local-exec" {
    command     = "echo Czekam na uruchomienie Windows 10... && ping -n 180 127.0.0.1 > nul"
    interpreter = ["cmd", "/C"]
  }
}

# Dołączanie komputera do domeny
resource "null_resource" "join_win10_to_domain" {
  depends_on = [null_resource.wait_for_win10_boot]

  provisioner "local-exec" {
    command     = "join_domain_win10.bat"
    interpreter = ["cmd", "/C"]
  }
}
