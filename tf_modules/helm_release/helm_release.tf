resource "helm_release" "helm_release" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true


  values = length(var.values) > 0 ? var.values : []


  dynamic "set" {
    for_each = var.helm_set_values
    content {
      name  = set.value.name
      value = set.value.value
      type  = lookup(set.value, "type", null)
    }
  }
}

