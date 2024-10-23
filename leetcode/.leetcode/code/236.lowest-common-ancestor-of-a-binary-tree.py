class Solution:
    def lowestCommonAncestor(self, root: 'TreeNode', p: 'TreeNode', q: 'TreeNode') -> 'TreeNode':
        self.ans = None
        
        def helper(root):
            if not root:
                return False

            left = helper(root.left)
            right = helper(root.right)

            mid = root == p or root == q

            return left or mid or right

