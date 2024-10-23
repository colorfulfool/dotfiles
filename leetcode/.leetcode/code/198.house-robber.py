from typing import List, Optional

class Solution:
    def rob(self, nums: List[int]) -> int:
        if len(nums) < 3:
            return max(nums)

        dp = [0] * len(nums)

        dp[0] = nums[0]
        dp[1] = max(nums[0], nums[1])

        for i in range(2, len(nums)):
            dont_rob = dp[i-1]
            rob = dp[i-2] + nums[i]
            dp[i] = max(dont_rob, rob)

        return dp[-1]
        
if __name__ == "__main__":
	print(Solution().rob([2,7,9,3,1])) # 12
