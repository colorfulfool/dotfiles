from typing import List, Optional

class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        dp = [0] * len(nums)

        dp[0] = nums[0]

        for i in range(len(nums)):
            cont = dp[i-1] + nums[i]
            new = nums[i]
            dp[i] = max(cont, new)

        print(dp)

        return max(dp)
        
if __name__ == "__main__":
	print(Solution().maxSubArray([-2,1,-3,4,-1,2,1,-5,4])) # 6
