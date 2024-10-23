from typing import List, Optional

class Solution:
    def sortArray(self, nums: List[int]) -> List[int]:
        if len(nums) <= 1:
            return nums

        pivot = nums[-1]

        left = self.sortArray([num for num in nums[:-1] if num <= pivot])
        right = self.sortArray([num for num in nums[:-1] if num > pivot])

        return left + [pivot] + right
        
if __name__ == "__main__":
	print(Solution().sortArray([4,3,2,5,1]))
