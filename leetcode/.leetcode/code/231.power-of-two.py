from typing import List, Optional

class Solution:
    def isPowerOfTwo(self, n: int) -> bool:
        return n & (n-1) == 0
        
if __name__ == "__main__":
	print(Solution().isPowerOfTwo(16))
