from typing import List, Optional

class Solution:
    def containsNearbyDuplicate(self, nums: List[int], k: int) -> bool:
        window = dict()

        for i in range(len(nums)):
            if nums[i] in window:
                if i - window[nums[i]] <= k:
                    return True

            window[nums[i]] = i

        return False
        
if __name__ == "__main__":
	print(Solution().containsNearbyDuplicate([1,0,1,1], 1))
