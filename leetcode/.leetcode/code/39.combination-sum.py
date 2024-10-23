from typing import List

class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        ans = []

        def backtrack(nums, path):
            if sum(path) > target:
                return

            if sum(path) == target:
                ans.append(path.copy())

            for i in range(len(nums)):
                path.append(nums[i])
                backtrack(nums[i:], path)
                path.pop()
            
        backtrack(candidates, [])

        return ans
        
