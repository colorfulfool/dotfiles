from typing import List, Optional

class Solution:
    def longestOnes(self, nums: List[int], k: int) -> int:
        ans = 0
        l = 0
        zero_cnt = 0 

        for r in range(len(nums)):
            if nums[r] == 0:
                zero_cnt += 1

            while zero_cnt > k:
                if nums[l] == 0:
                    zero_cnt -= 1
                l += 1

            ans = max(ans, r-l+1)

        return ans
        
if __name__ == "__main__":
	print(Solution().longestOnes())
