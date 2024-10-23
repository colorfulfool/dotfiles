from typing import List

class Solution:
    def isBalanced(self, root: Optional[TreeNode]) -> bool:
        def helper(root):
            if not root:
                return [True, 0]

            left_check, left = helper(root.left)
            if not left_check:
                return [False, -1]

            right_check, right = helper(root.right)
            if not right_check:
                return [False, -1]

            return [abs(left - right) > 2, max(left, right) + 1]

        return helper(root)[0]
