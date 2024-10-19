from typing import List, Optional

class Solution:
    def lowestCommonAncestor(self, root: 'TreeNode', p: 'TreeNode', q: 'TreeNode') -> 'TreeNode':
        self.ans = None        

        def helper(root):
            if not root:
                return False

            left = helper(root.left)
            right = helper(root.right)

            mid = root == p or root == q

            if left + mid + right >= 2:
                self.ans = root

            return left or mid or right

        helper(root)

        return self.ans
