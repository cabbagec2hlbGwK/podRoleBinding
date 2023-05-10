
output "trust_role" {
  value = aws_iam_role.trust_relationship.id
}
output "K8sHost" {
  value = data.aws_eks_cluster.cluster.endpoint
}
output "K8sCa" {
  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
output "K8sToken" {
  value = data.aws_eks_cluster_auth.cluster.token
}
