module "blue1" {
  source                    = "../blue-green_attachment"
  color                     = "blue"
  name                      = var.name
  max_size                  = var.blue_max_size
  min_size                  = var.blue_min_size
  desired_capacity          = var.blue_desired_capacity
  ami_key_pair_name         = "MyKP"
}

module "green1" {
  source                    = "../blue-green_attachment"
  color                     = "green"
  name                      =  var.name
  max_size                  = var.green_max_size
  min_size                  = var.green_min_size
  desired_capacity          = var.green_desired_capacity
  ami_key_pair_name         = "MyKP"
}