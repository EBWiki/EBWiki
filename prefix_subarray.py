from collections import defaultdict

def subarray_sum(nums, k):
    prefix_sum_count = defaultdict(int)

    prefix_sum_count[0] = 1  # base case

    curr_sum = 0

    count = 0

    for num in nums:

        curr_sum += num

        count += prefix_sum_count[curr_sum - 1]

        prefix_sum_count[curr_sum] += 1

        return count
    end


print (subarray_sum([10, -3, 2,1,6,-4, 3,8,2,-1, 4,2], 6))
#print (subarray_sum([1, 1, 1],2))
#print (subarray_sum([1, 2, 3],3))

