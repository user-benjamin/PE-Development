##Template files are no longer supported
##Todo: don't do this
[
  {
    "name": "demo-container",
    "image": "676636886737.dkr.ecr.us-east-1.amazonaws.com/challenge5:latest",
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
               "awslogs-group":"bg-challenge5",
               "awslogs-region":"us-east-1",
               "awslogs-stream-prefix":"ecs"
            }
      },
       "secrets": [
      {
        "name": "DB_PASS",
        "valueFrom": "${database_password}"
      }
    ],
     "environment": [
      {
        "name": "DB_USER",
        "value": "root"
      },
      {
          "name": "DB_HOST",
          "value": "bensrds.cbyh4d7g3lso.us-east-1.rds.amazonaws.com"
      },
      {
          "name": "DB_SCHEMA",
          "value": "foo"
      }
    ]
  }
]
