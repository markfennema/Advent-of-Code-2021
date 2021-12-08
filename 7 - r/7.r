# Sneaking in R on a day where I know it's simple math. I do not like this language.

num_strs <- scan("input.txt", what="character", sep=",")
nums <- as.numeric(num_strs)

# P1
p1_target <- median(nums)
sum(abs(rep(p1_target, 1000) - nums))

# P2
p2_target <- floor(mean(nums))
sum(sapply(nums, function(x) (abs(x - p2_target) * (abs(x - p2_target) + 1))/2))