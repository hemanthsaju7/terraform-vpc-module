output "myvpc" {
  value = aws_vpc.main.id
}

output "public1" {
  value = aws_subnet.public1.id
}

output "public2" {
  value = aws_subnet.public2.id
}

output "public3" {
  value = aws_subnet.public3.id
}

output "private1" {
  value = aws_subnet.private1.id
}
  
output "private2" {
  value = aws_subnet.private2.id
}
  
output "private3" {
  value = aws_subnet.private3.id
}
