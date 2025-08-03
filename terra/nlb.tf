resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-TG"
  port        = 5000
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.mern_vpc.id

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "mongo_tg" {
  name        = "mongo-TG"
  port        = 8081
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.mern_vpc.id

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "backend_attachments" {
  count            = 3
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.backend_ec2[count.index].id
  port             = 5000
}

resource "aws_lb_target_group_attachment" "mongo_attachment" {
  target_group_arn = aws_lb_target_group.mongo_tg.arn
  target_id        = aws_instance.mongodb_ec2.id
  port             = 8081
}


resource "aws_lb" "public_nlb" {
  name               = "Public-NLB-TG"
  internal           = false
  load_balancer_type = "network"
  ip_address_type    = "ipv4"
  subnets            = [aws_subnet.public_subnet.id]
  tags = {
    Name = "Public-NLB-TG"
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.public_nlb.arn
  port              = 5000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_lb_listener" "mongo_listener" {
  load_balancer_arn = aws_lb.public_nlb.arn
  port              = 8081
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mongo_tg.arn
  }
}
