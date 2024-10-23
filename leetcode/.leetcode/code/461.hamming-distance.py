from typing import List, Optional

class Solution:
    def hammingDistance(self, x: int, y: int) -> int:
        n = x ^ y

        ans = 0

        while n:
            ans += n & 1
            n >>= 1

        return ans
        
if __name__ == "__main__":
	print(Solution().hammingDistance(1,4))
