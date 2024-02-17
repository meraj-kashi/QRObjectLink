# Local variables
locals {
  name = var.name
}

locals {
  tags = merge(var.tags, { Name = local.name }, { Environment = var.environment })
}

locals {
  name_prefix = "${local.name}-${var.environment}"
}
