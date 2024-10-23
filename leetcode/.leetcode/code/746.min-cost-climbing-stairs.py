from typing import List, Optional
from functools import lru_cache

class Solution:
    def minCostClimbingStairs(self, cost: List[int]) -> int:
        @lru_cache
        def dp(i):
            if i < 2:
                return 0

            total1 = cost[i-1] + dp(i-1)
            total2 = cost[i-2] + dp(i-2)

            return min(total1, total2)

        return dp(len(cost))
        
if __name__ == "__main__":
	print(Solution().minCostClimbingStairs([10,15,20]))
