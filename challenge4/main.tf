resource "aws_iam_role" "ben_iam_for_ecs" {
  name = "ben-iam-for-ecs"
  assume_role_policy = data.aws_iam_policy_document.ben_iam_for_ecs.json

    inline_policy {
    name = "ben_iam_for_ecs"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "ecs:*", 
            "ecr:*",
            "ecr:GetAuthorizationToken", 
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
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

resource "aws_ecr_repository" "challenge4" {
  name = "challenge4"
}

resource "aws_ecr_repository_policy" "challenge4" {
  repository = aws_ecr_repository.challenge4.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the challenge4 repository",
        "Effect": "Allow",
        "Principal": "AWS": "arn:aws:iam::676636886737:AWSReservedSSO_SandboxAdmin_d342697e7fcc0f35/bglover"
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

resource "aws_ecs_cluster" "challenge4ecs" {
  name = "challenge4ecs"
}

resource "aws_ecs_service" "demo-ecs-service-two" {
  name            = "demo-app"
  cluster         = aws_ecs_cluster.challenge4ecs.id
  task_definition = aws_ecs_task_definition.demo-ecs-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-0ce529e158b34a78b"]
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_egress_all.id]
  }
  desired_count = 1
}

resource "aws_ecs_task_definition" "demo-ecs-task-definition" {
  family                   = "ecs-task-definition-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn = aws_iam_role.ben_iam_for_ecs.arn
  container_definitions    = <<EOF
[
  {
    "name": "demo-container",
    "image": "676636886737.dkr.ecr.us-east-1.amazonaws.com/challenge4:latest",
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "entryPoint": ["./app"],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration":{
            "logDriver":"awslogs",
            "options":{
               "awslogs-group":"bg-challenge4",
               "awslogs-region":"us-east-1",
               "awslogs-stream-prefix":"ecs"
            }
      }
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "bg-challenge4" {
  name = "bg-challenge4"

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
