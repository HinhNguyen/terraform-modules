# Nothing in this main()

# To newbie, I create following tf files:
# - VPC and network infrastructure
# - IAM role and user
# - other services
#
# tags = "${merge(
#   var.common-tags, 
#   map(
#     "Name", "${var.environment}-${var.project}-service_name" 
# ))}"