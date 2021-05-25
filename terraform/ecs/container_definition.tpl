  [{
    "name": "app",
    "image": "${image_path}",
    "memory": 256,
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ]
  }]