from typing import List

mapping = {
    "2": "abc",
    "3": "def",
    "4": "ghi",
    "5": "jkl",
    "6": "mno",
    "7": "pqrs",
    "8": "tuv",
    "9": "wxyz",
}

class Solution:
    def letterCombinations(self, digits: str) -> List[str]:
        if not digits:
            return []

        ans = []

        def backtrack(level: int,  path: List[str]):
            if level == len(digits):
                ans.append("".join(path))
                return

            for i, letter in enumerate(list(mapping[digits[level]])):
                path.append(letter)
                backtrack(level+1, path)
                path.pop()

        backtrack(0, [])

        return ans
        
