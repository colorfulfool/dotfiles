from typing import List

class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        ans = []        

        def backtrack(nums, path):
            ans.append(path.copy())

            if not nums:
                return

            for i, num in enumerate(nums):
                path.append(num)
                backtrack(nums[i+1:], path)
                path.pop()

        backtrack(nums, [])

        return ans
