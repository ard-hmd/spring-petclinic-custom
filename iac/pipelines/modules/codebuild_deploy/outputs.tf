output "id" { 
    count = length(var.service_name)
    value = aws_codebuild_project.build[count.index].id }