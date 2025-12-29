resource "aws_security_group" "alb" {
  name        = "helloapp-alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "helloapp-alb-sg" }
}

resource "aws_lb" "this" {
  name               = "helloapp-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = { Name = "helloapp-alb" }
}

resource "aws_lb_target_group" "this" {
  name        = "helloapp-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/hello"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
