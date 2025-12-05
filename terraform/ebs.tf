resource "aws_ebs_volume" "mariadb" {
  count             = var.enable_mariadb_volume ? 1 : 0
  availability_zone = aws_instance.worker[0].availability_zone
  size              = 2
  type              = "gp3"
  encrypted         = true

  tags = {
    Name    = "${var.cluster_name}-mariadb-pv"
    Purpose = "Q11-MariaDB-Persistent-Volume"
  }
}

resource "aws_volume_attachment" "mariadb" {
  count       = var.enable_mariadb_volume ? 1 : 0
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.mariadb[0].id
  instance_id = aws_instance.worker[0].id
}
