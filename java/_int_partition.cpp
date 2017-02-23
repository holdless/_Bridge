/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package testdp;

/**
 *
 * @author changyht
 */
public class TestDP {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
        int m = 6;
        int n = m + 1;
        int[] M;
        M = new int[n];
        for (int i = 0; i < n; i++)
            M[i] = -1;
        M[0] = 0;
        M[1] = 1;
        
        int result = fi(m, M);
        System.out.println(result);
        
    }
    
    // top down: recursion
    public static int fr(int m, int[] M)
    {
        if (M[m] == -1) // check if it is already calculated!
        {
            M[m] = fr(m-1, M) + fr(m-2, M);
            return M[m];
        }
        else
            return M[m];
    }
    
    // bottom up: iteration
    public static int fi(int m, int[] M)
    {
        for (int i = 0; i <= m; i++)
        {
            if (M[i] == -1)
                M[i] = M[i-1] + M[i-2];
        }
        return M[m];
    }    
}
