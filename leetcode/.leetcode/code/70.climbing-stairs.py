from typing import List, Optional
from functools import lru_cache

class Solution:
    @lru_cache()
    def climbStairs(self, n: int) -> int:
        if n < 0:
            return 0

        if n == 0:
            return 1

        one = self.climbStairs(n-1)
        two = self.climbStairs(n-2)

        return one + two
        
if __name__ == "__main__":
	print(Solution().climbStairs(3))
