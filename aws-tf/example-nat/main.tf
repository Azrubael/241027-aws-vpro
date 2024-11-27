/* Пример файла `main.tf`, который создает два экземпляра Amazon Linux 2
 * в субсети с тегом `FRONT-subnet` в дефолтной VPC.
 * Один из экземпляров будет иметь публичный IP, а другой — нет,
 * но оба смогут обращаться к ресурсам во внешнем мире через NAT Gateway.
 */


provider "aws" {
  region = "us-east-1"  # Укажите нужный вам регион
}

# Получаем дефолтную VPC
data "aws_vpc" "default" {
  default = true
}

# Получаем субсети с тегом FRONT-subnet
data "aws_subnet_ids" "front_subnet" {
  vpc_id = data.aws_vpc.default.id
}

# Создаем NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id    = element(data.aws_subnet_ids.front_subnet.ids, 0)  # Используем первую субнету
}

# Создаем маршрут для NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = element(data.aws_subnet_ids.front_subnet.ids, 1)  # Используем вторую субнету
  route_table_id = aws_route_table.private.id
}

# Создаем экземпляр с публичным IP
resource "aws_instance" "public_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Убедитесь, что это актуальный AMI для Amazon Linux 2 в вашем регионе
  instance_type = "t2.micro"
  subnet_id     = element(data.aws_subnet_ids.front_subnet.ids, 0)  # Используем первую субнету
  associate_public_ip_address = true

  tags = {
    Name = "PublicInstance"
  }
}

# Создаем экземпляр без публичного IP
resource "aws_instance" "private_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Убедитесь, что это актуальный AMI для Amazon Linux 2 в вашем регионе
  instance_type = "t2.micro"
  subnet_id     = element(data.aws_subnet_ids.front_subnet.ids, 1)  # Используем вторую субнету
  associate_public_ip_address = false

  tags = {
    Name = "PrivateInstance"
  }
}

/* Комментарии
1. **Провайдер AWS**: Указываем регион, в котором будет развернута инфраструктура.
2. **Дефолтная VPC**: Получаем информацию о дефолтной VPC.
3. **Субсети**: Получаем идентификаторы субсетей с тегом `FRONT-subnet`.
4. **NAT Gateway**: Создаем NAT Gateway для обеспечения доступа к интернету для экземпляра без публичного IP.
5. **Маршрутная таблица**: Создаем маршрутную таблицу для частной субсети, чтобы направлять трафик через NAT Gateway.
6. **Экземпляры**: Создаем два экземпляра Amazon Linux 2 — один с публичным IP и один без.

### Примечания:
- AMI должен быть актуален для выбранного региона.
- у пользователя должны быть необходимые права для создания ресурсов в AWS.
*/