from typing import List, Optional
from functools import lru_cache

class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        dp = [[1] * n for _ in range(m)]

        for i in range(1, m):
            for j in range(1, n):
                dp[i][j] = dp[i][j-1] + dp[i-1][j]

        return dp[-1][-1]
        
if __name__ == "__main__":
	print(Solution().uniquePaths(3, 7)) # 28
