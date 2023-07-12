resource "aws_iam_role" "ben_iam_for_ecs" {
  name               = "ben-iam-for-ecs"
  assume_role_policy = data.aws_iam_policy_document.ben_iam_for_ecs.json

  inline_policy {
    name = "ben_iam_for_ecs"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecs:*",
            "ecr:*",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ssm:GetParameters"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

data "aws_iam_policy_document" "ben_iam_for_ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_ecr_repository" "challenge5" {
  name = "challenge5"
}

resource "aws_ecr_repository_policy" "challenge5" {
  repository = aws_ecr_repository.challenge5.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the challenge5 repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecs_cluster" "challenge5ecs" {
  name = "challenge5ecs"
}

resource "aws_ecs_service" "demo-ecs-service-two" {
  name            = "demo-app"
  cluster         = aws_ecs_cluster.challenge5ecs.id
  task_definition = aws_ecs_task_definition.demo-ecs-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-0ce529e158b34a78b"]
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_egress_all.id]
  }
  desired_count = 1
}

data "template_file" "task_template_parameterstore" {
  template = file("./task_def.tpl")
  vars = {
    database_password = aws_ssm_parameter.database_password_parameter.arn
  }
}
resource "aws_ecs_task_definition" "demo-ecs-task-definition" {
  family                   = "ecs-task-definition-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = aws_iam_role.ben_iam_for_ecs.arn
  container_definitions    = data.template_file.task_template_parameterstore.rendered
}

resource "aws_ssm_parameter" "database_password_parameter" {
  name        = "/sandbox/database/password/master"
  description = "sandbox environment database password"
  type        = "SecureString"
  value       = "changeme"
}

resource "aws_cloudwatch_log_group" "bg-challenge5" {
  name = "bg-challenge5"

  tags = {
    Environment = "noc-sandbox"
    Application = "test-demo-challenge"
  }
}

resource "aws_security_group" "allow_egress_all" {
  name        = "allow_egress_all"
  description = "Allow outbound traffic"
  vpc_id      = "vpc-06d3f8ac2206caa8b"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-egress-all"
  }
}
