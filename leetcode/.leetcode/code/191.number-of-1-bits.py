from typing import List, Optional

class Solution:
    def hammingWeight(self, n: int) -> int:
        ans = 0

        while n:
            ans += n & 1
            n >>= 1

        return ans
        
if __name__ == "__main__":
	print(Solution().hammingWeight(2147483645))
