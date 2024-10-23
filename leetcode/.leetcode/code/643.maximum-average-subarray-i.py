from typing import List, Optional

class Solution:
    def findMaxAverage(self, nums: List[int], k: int) -> float:
        ans = cumsum = sum(nums[:k])

        for i in range(k, len(nums)):
            cumsum -= nums[i-k]
            cumsum += nums[i]
            ans = max(ans, cumsum)

        return ans / k
        
if __name__ == "__main__":
	print(Solution().findMaxAverage([1,12,-5,-6,50,3], 4)) # 12.75
